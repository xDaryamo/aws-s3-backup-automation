# Automated AWS S3 Backup System

## Project Overview
Small and medium-sized enterprises often rely on manual backup processes that are inconsistent and prone to human error. This project provides an automated, off-site backup solution using Amazon S3 to ensure data integrity, security, and cost-efficiency without manual intervention.

## Architecture
The following diagram illustrates the automated workflow. The On-Premise server triggers the backup process daily, synchronizing local data with specialized AWS S3 buckets.

![Architecture Diagram](docs/architecture.svg)

## Technical Implementation
- **Incremental Uploads**: The script compares local file sizes with existing S3 objects before uploading. If a file is already present and unchanged, the upload is skipped to optimize bandwidth and reduce API costs.
- **Data Categorization**: The Python script automatically sorts files into specific S3 buckets (Documents, Photos, Database) based on file extensions.
- **Disaster Recovery**: S3 Versioning is enabled to allow point-in-time recovery.
- **Cost Optimization**: Infrastructure is configured with S3 Lifecycle Policies. Data is automatically transitioned to lower-cost storage classes (Standard-IA and S3 Glacier) after 30 and 60 days.
- **Proactive Monitoring**: Integrated with Amazon SNS to deliver a status report via email after each execution.

## Tech Stack
- **Language**: Python 3.11 (Boto3 SDK)
- **Infrastructure as Code**: Terraform
- **Cloud Services**: Amazon S3, Amazon SNS, AWS IAM

## Automation and Scheduling
In a production environment, this system is designed to be fully autonomous. The backup script is intended to be scheduled as a **CronJob** on a local server or within a containerized orchestrator. 

Example configuration for a daily backup at 02:00 AM:
```bash
0 2 * * * /usr/bin/python3 /path/to/backup.py >> /var/log/s3_backup.log 2>&1
```
This ensures that data is backed up during off-peak hours, minimizing impact on network performance and ensuring consistent daily recovery points.

## Production Verification Logs
The following logs demonstrate a real execution of the system, showing the successful upload of files and the subsequent verification using the AWS CLI.

### 1. Python Script Execution
The script identifies files in the `sample_data/` directory and performs an incremental sync.

```text
2026-02-11 02:00:01,372 - INFO - Starting incremental backup from directory: ./sample_data
2026-02-11 02:00:01,567 - INFO - File meeting_notes.txt already up to date in dariomazza-backup-documents, skipping.
2026-02-11 02:00:01,748 - INFO - File sample_image.jpg already up to date in dariomazza-backup-photos, skipping.
2026-02-11 02:00:01,789 - INFO - File project_report.pdf already up to date in dariomazza-backup-documents, skipping.
2026-02-11 02:00:01,974 - INFO - File prod_db_backup.sql already up to date in dariomazza-backup-database, skipping.
2026-02-11 02:00:01,974 - INFO - Backup completed.
Files uploaded: 0
Files skipped (already exist): 4
Errors encountered: 0
2026-02-11 02:00:02,140 - INFO - SNS notification sent successfully.
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