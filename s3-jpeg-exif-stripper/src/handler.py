import json
import boto3
from utils import strip_exif_metadata

s3_client = boto3.client('s3')

def lambda_handler(event, context):
    # Get the bucket name and object key from the event
    source_bucket = event['Records'][0]['s3']['bucket']['name']
    object_key = event['Records'][0]['s3']['object']['key']
    
    # Check if the uploaded file is a .jpg
    if object_key.lower().endswith('.jpg'):
        # Retrieve the image from S3
        response = s3_client.get_object(Bucket=source_bucket, Key=object_key)
        image_data = response['Body'].read()
        
        # Strip EXIF metadata
        cleaned_image = strip_exif_metadata(image_data)
        
        # Define the destination bucket and upload the cleaned image
        destination_bucket = 'your-destination-bucket-name'  # Replace with your destination bucket name
        s3_client.put_object(Bucket=destination_bucket, Key=object_key, Body=cleaned_image)
        
        return {
            'statusCode': 200,
            'body': json.dumps('EXIF metadata stripped and image uploaded successfully.')
        }
    
    return {
        'statusCode': 400,
        'body': json.dumps('Uploaded file is not a .jpg image.')
    }