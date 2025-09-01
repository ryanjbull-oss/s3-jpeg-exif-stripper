# s3-jpeg-exif-stripper

## Overview
This project provides an AWS Lambda function that automatically processes .jpg images uploaded to a specified S3 bucket (Bucket A) by stripping any EXIF metadata. The cleaned images are then saved to another S3 bucket (Bucket B) while preserving the original file paths.

## Project Structure
```
s3-jpeg-exif-stripper
├── src
│   ├── handler.py        # AWS Lambda function handler
│   └── utils.py          # Utility functions for image processing
├── requirements.txt      # Python dependencies
├── README.md             # Project documentation
├── main.tf               # Terraform configuration
```

## Setup Instructions

1. **Clone the repository:**
   ```
   git clone https://github.com/your-repo/s3-jpeg-exif-stripper.git
   cd s3-jpeg-exif-stripper
   ```

2. **Install dependencies:**
   Ensure you have Python and pip installed, then run:
   ```
   pip install -r requirements.txt
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
   Zip your Lambda source code and dependencies:
   ```
   cd src
   pip install -r ../requirements.txt -t .
   zip -r ../lambda_function.zip .
   cd ..
   ```
   Upload `lambda_function.zip` to an S3 bucket (e.g., `your-code-bucket-name`).

5. **Update Terraform variables:**
   Edit `main.tf` and set the correct values for:
   - `s3_bucket` (the bucket where you uploaded `lambda_function.zip`)
   - `s3_key` (the key/path to `lambda_function.zip` in the bucket)
   - S3 bucket names for source and destination

6. **Deploy the infrastructure with Terraform:**
   ```
   terraform init
   terraform apply
   ```

## Usage
Once deployed, the Lambda function will automatically trigger whenever a .jpg file is uploaded to Bucket A. The function will:
- Retrieve the uploaded image.
- Strip any EXIF metadata using the utility function.
- Upload the cleaned image to Bucket B, maintaining the original file path.

## Functionality
- **EXIF Metadata Stripping:** The project utilizes the Pillow library to handle image processing and remove EXIF data.
- **S3 Integration:** The function uses the Boto3 library to interact with AWS S3 for file retrieval and storage.

## Contributing
Contributions are welcome! Please submit a pull request or open an issue for any enhancements or bug fixes.

## License
This project is licensed under the MIT License. See the LICENSE file