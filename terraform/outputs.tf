output "s3_bucket_name" {
  description = "The name of the S3 bucket created."
  value       = aws_s3_bucket.backup_bucket.bucket
}

output "iam_user_access_key_id" {
  description = "The access key ID for the IAM user."
  value       = aws_iam_access_key.s3_backup_user_key.id
}

output "iam_user_secret_access_key" {
  description = "The secret access key for the IAM user."
  value       = aws_iam_access_key.s3_backup_user_key.secret
  sensitive   = true
}

output "iam_user_name" {
  description = "The name of the IAM user created."
  value       = aws_iam_user.s3_backup_user.name
}
