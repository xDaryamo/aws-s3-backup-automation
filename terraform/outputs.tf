output "s3_bucket_names" {
  description = "The names of the S3 buckets created."
  value       = { for k, b in aws_s3_bucket.backup_buckets : k => b.bucket }
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic for notifications."
  value       = aws_sns_topic.backup_notifications.arn
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
