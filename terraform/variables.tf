variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "eu-south-1"
}

variable "s3_bucket_name" {
  description = "Name for the S3 bucket."
  type        = string
  default     = "dariomazza-s3-backup-automation-2026"
}

variable "iam_user_name" {
  description = "Name for the IAM user to be created for S3 access."
  type        = string
  default     = "aws-s3-backup-user"
}
