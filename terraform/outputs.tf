output "s3_bucket_names" {
  description = "The names of the S3 buckets created."
  value       = module.s3.bucket_names
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic for notifications."
  value       = module.sns.topic_arn
}

output "iam_user_access_key_id" {
  description = "The access key ID for the IAM user."
  value       = module.iam.access_key_id
}

output "iam_user_secret_access_key" {
  description = "The secret access key for the IAM user."
  value       = module.iam.secret_access_key
  sensitive   = true
}

output "iam_user_name" {
  description = "The name of the IAM user created."
  value       = module.iam.user_name
}
