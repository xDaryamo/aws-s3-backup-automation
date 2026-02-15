output "access_key_id" {
  description = "The access key ID for the IAM user."
  value       = aws_iam_access_key.s3_backup_user_key.id
}

output "secret_access_key" {
  description = "The secret access key for the IAM user."
  value       = aws_iam_access_key.s3_backup_user_key.secret
  sensitive   = true
}

output "user_name" {
  description = "The name of the IAM user."
  value       = aws_iam_user.s3_backup_user.name
}
