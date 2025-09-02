data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "source" {
  bucket = "source-bucket-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket" "destination" {
  bucket = "destination-bucket-${data.aws_caller_identity.current.account_id}"
}

resource "aws_iam_user" "all_users" {
  for_each = toset(concat(var.users_write, var.users_read))
  name     = each.value
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_s3_exif_stripper_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "lambda_s3_policy" {
  name = "lambda_s3_exif_stripper_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.source.arn}/*",
          "${aws_s3_bucket.destination.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}

# Write access policy for source
data "aws_iam_policy_document" "bucket_source" {
  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.source.arn}/*"]
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.source.arn]
  }
}

resource "aws_iam_policy" "bucket_source" {
  name   = "bucket-source-rw-policy"
  policy = data.aws_iam_policy_document.bucket_source.json
}

resource "aws_iam_user_policy_attachment" "rw_users_attach" {
  for_each   = toset(var.users_write)
  user       = aws_iam_user.all_users[each.key].name
  policy_arn = aws_iam_policy.bucket_source.arn
}

# Read-only access policy for destination
data "aws_iam_policy_document" "bucket_destination" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.destination.arn}/*"]
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.destination.arn]
  }
}

resource "aws_iam_policy" "bucket_destination" {
  name   = "bucket-destination-ro-policy"
  policy = data.aws_iam_policy_document.bucket_destination.json
}

resource "aws_iam_user_policy_attachment" "ro_users_attach" {
  for_each   = toset(var.users_read)
  user       = aws_iam_user.all_users[each.key].name
  policy_arn = aws_iam_policy.bucket_destination.arn
}

# Probably would be better to use s3 instead of packaging here but this
# simplifies the to deployment for now
data "archive_file" "strip_exif" {
  type        = "zip"
  source_dir  = "${path.module}/../src"
  output_path = "${path.module}/../lambda_function_payload.zip"
}

resource "aws_lambda_function" "strip_exif" {
  function_name = "strip-exif-lambda"
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"
  role          = aws_iam_role.lambda_exec.arn
  memory_size   = 128
  timeout       = 30

  filename         = data.archive_file.strip_exif.output_path
  source_code_hash = data.archive_file.strip_exif.output_base64sha256
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.strip_exif.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.source.arn
}

resource "aws_s3_bucket_notification" "source_notification" {
  bucket = aws_s3_bucket.source.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.strip_exif.arn
    events              = ["s3:ObjectCreated:Put"]
    filter_prefix       = ""
    filter_suffix       = ".jpg"
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

output "lambda_function_arn" {
  value = aws_lambda_function.strip_exif.arn
}

output "source_bucket" {
  value = aws_s3_bucket.source.bucket
}

output "destination_bucket" {
  value = aws_s3_bucket.destination.bucket
}