variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "eu-south-1"
}

variable "s3_bucket_prefix" {
  description = "Prefix for the S3 buckets."
  type        = string
  default     = "dariomazza-aws-backup-2026"
}

variable "bucket_categories" {
  description = "List of bucket categories to create."
  type        = list(string)
  default     = ["documents", "photos", "database"]
}

variable "iam_user_name" {
  description = "Name for the IAM user to be created for S3 access."
  type        = string
  default     = "aws-s3-backup-user"
}

variable "alert_email" {
  description = "Email address for backup notifications."
  type        = string
}
