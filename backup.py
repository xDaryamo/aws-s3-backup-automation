import os
import boto3
import logging
from pathlib import Path
from botocore.exceptions import ClientError

# Logging Configuration
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def get_bucket_for_extension(extension):
    """Determines the target bucket based on the file extension."""
    mapping = {
        '.pdf': os.getenv('S3_BUCKET_DOCUMENTS'),
        '.txt': os.getenv('S3_BUCKET_DOCUMENTS'),
        '.jpg': os.getenv('S3_BUCKET_PHOTOS'),
        '.png': os.getenv('S3_BUCKET_PHOTOS'),
        '.sql': os.getenv('S3_BUCKET_DATABASE'),
        '.db':  os.getenv('S3_BUCKET_DATABASE'),
    }
    # Default to documents bucket if extension is not mapped
    return mapping.get(extension.lower(), os.getenv('S3_BUCKET_DOCUMENTS'))

def file_exists_and_same(s3_client, bucket, key, local_path):
    """Checks if a file exists in S3 and has the same size as the local file."""
    try:
        response = s3_client.head_object(Bucket=bucket, Key=key)
        remote_size = response['ContentLength']
        local_size = os.path.getsize(local_path)
        
        if remote_size == local_size:
            return True
    except ClientError as e:
        if e.response['Error']['Code'] != "404":
            logger.error(f"Error checking S3 for {key}: {e}")
    return False

def send_notification(sns_client, topic_arn, message):
    """Sends a notification via Amazon SNS."""
    try:
        sns_client.publish(
            TopicArn=topic_arn,
            Message=message,
            Subject="Automated Backup - Daily Report"
        )
        logger.info("SNS notification sent successfully.")
    except Exception as e:
        logger.error(f"Failed to send SNS notification: {e}")

def main():
    source_dir = os.getenv('SOURCE_DIR', './sample_data')
    sns_topic_arn = os.getenv('SNS_TOPIC_ARN')
    
    # Initialize AWS Clients
    s3 = boto3.client('s3')
    sns = boto3.client('sns')
    
    files_backed_up = 0
    files_skipped = 0
    errors = []

    logger.info(f"Starting incremental backup from directory: {source_dir}")

    path = Path(source_dir)
    if not path.exists():
        logger.error(f"Source directory {source_dir} not found!")
        return

    for file_path in path.iterdir():
        if file_path.is_file():
            bucket_name = get_bucket_for_extension(file_path.suffix)
            
            if not bucket_name:
                logger.warning(f"No bucket configured for {file_path.name}, skipping.")
                continue

            # Incremental Check
            if file_exists_and_same(s3, bucket_name, file_path.name, str(file_path)):
                logger.info(f"File {file_path.name} already up to date in {bucket_name}, skipping.")
                files_skipped += 1
                continue

            try:
                logger.info(f"Uploading {file_path.name} to {bucket_name}...")
                s3.upload_file(str(file_path), bucket_name, file_path.name)
                files_backed_up += 1
            except Exception as e:
                error_msg = f"Error uploading {file_path.name}: {e}"
                logger.error(error_msg)
                errors.append(error_msg)

    # Final Report
    report = (
        f"Backup completed.\n"
        f"Files uploaded: {files_backed_up}\n"
        f"Files skipped (already exist): {files_skipped}\n"
        f"Errors encountered: {len(errors)}"
    )
    if errors:
        report += "\n\nError details:\n" + "\n".join(errors)
    
    logger.info(report)

    if sns_topic_arn:
        send_notification(sns, sns_topic_arn, report)
    else:
        logger.warning("SNS_TOPIC_ARN not set, notification skipped.")

if __name__ == "__main__":
    main()