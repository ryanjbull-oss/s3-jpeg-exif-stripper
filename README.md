# s3-jpeg-exif-stripper

## Overview
This project provides an AWS Lambda function that automatically processes .jpg images uploaded to a specified S3 bucket (Bucket A) by stripping any EXIF metadata. The cleaned images are then saved to another S3 bucket (Bucket B) while preserving the original file paths.

## Setup Instructions

1. **Clone the repository:**
   ```
   git clone https://github.com/your-repo/s3-jpeg-exif-stripper.git
   cd s3-jpeg-exif-stripper
   ```

3. **Configure AWS Credentials:**
   Make sure your AWS credentials are configured. You can set them up using the AWS CLI:
   ```
   aws configure
   ```
   Or set them as environment variables in your terminal:
   ```
   set AWS_ACCESS_KEY_ID=your-access-key-id
   set AWS_SECRET_ACCESS_KEY=your-secret-access-key
   ```

4. **Build and package the Lambda function:**
   Setup your Lambda source code and dependencies:
   ```
   cd src
   pip install -r ../requirements.txt -t .
   cd ..
   ```

5. **Deploy the infrastructure with Terraform:**
   ```
   terraform -chdir=infra\ terraform init
   terraform -chdir=infra\ terraform apply
   ```

## Usage
Once deployed, the Lambda function will automatically trigger whenever a .jpg file is uploaded to Bucket A. The function will:
- Retrieve the uploaded image.
- Strip any EXIF metadata using the utility function.
- Upload the cleaned image to Bucket B, maintaining the original file path.

## License
This project is licensed under the MIT License. See the LICENSE file