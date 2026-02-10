# Automated AWS S3 Backup System

## Project Overview
Small and medium-sized enterprises often rely on manual backup processes that are inconsistent and prone to human error. This project provides an automated, off-site backup solution using Amazon S3 to ensure data integrity, security, and cost-efficiency without manual intervention.

## Architecture
The following diagram illustrates the automated workflow. The On-Premise server triggers the backup process daily, synchronizing local data with specialized AWS S3 buckets.

![Architecture Diagram](docs/architecture.svg)

## Technical Implementation
- **Data Categorization**: The Python script automatically sorts files into specific S3 buckets (Documents, Photos, Database) based on file extensions.
- **Disaster Recovery**: S3 Versioning is enabled to allow point-in-time recovery.
- **Cost Optimization**: Infrastructure is configured with S3 Lifecycle Policies. Data is automatically transitioned to lower-cost storage classes (Standard-IA and S3 Glacier) after 30 and 60 days.
- **Proactive Monitoring**: Integrated with Amazon SNS to deliver a status report via email after each execution.

## Tech Stack
- **Language**: Python 3.11 (Boto3 SDK)
- **Infrastructure as Code**: Terraform
- **Cloud Services**: Amazon S3, Amazon SNS, AWS IAM

## Production Verification Logs
The following logs demonstrate a real execution of the system, showing the successful upload of files and the subsequent verification using the AWS CLI.

### 1. Python Script Execution
The script identifies files in the `sample_data/` directory and uploads them to the corresponding S3 buckets based on file type.

```text
2026-02-11 02:00:01,519 - INFO - Starting backup from directory: ./sample_data
2026-02-11 02:00:01,520 - INFO - Uploading meeting_notes.txt to dariomazza-aws-backup-2026-documents...
2026-02-11 02:00:01,771 - INFO - Uploading sample_image.jpg to dariomazza-aws-backup-2026-photos...
2026-02-11 02:00:02,514 - INFO - Uploading project_report.pdf to dariomazza-aws-backup-2026-documents...
2026-02-11 02:00:02,605 - INFO - Uploading prod_db_backup.sql to dariomazza-aws-backup-2026-database...
2026-02-11 02:00:02,880 - INFO - Backup completed.
Files successfully saved: 4
Errors encountered: 0
2026-02-11 02:00:03,044 - INFO - SNS notification sent successfully.
```

### 2. AWS Infrastructure Verification
Verifying the content of the S3 buckets confirms that the files were correctly routed and stored.

**Bucket: Documents**
```bash
$ aws s3 ls s3://dariomazza-aws-backup-2026-documents
2026-02-11 02:00:02         71 meeting_notes.txt
2026-02-11 02:00:02        490 project_report.pdf
```

**Bucket: Photos**
```bash
$ aws s3 ls s3://dariomazza-aws-backup-2026-photos
2026-02-11 02:00:02    1798761 sample_image.jpg
```

**Bucket: Database**
```bash
$ aws s3 ls s3://dariomazza-aws-backup-2026-database
2026-02-11 02:00:02        128 prod_db_backup.sql
```

## Business Impact
- **Operational Reliability**: Eliminates human error by automating the entire backup lifecycle.
- **Data Durability**: Leverages AWS infrastructure (99.999999999% durability).
- **Financial Efficiency**: Reduces storage costs through automated data tiering.
- **Scalability**: Capable of handling increasing data volumes without code modification.