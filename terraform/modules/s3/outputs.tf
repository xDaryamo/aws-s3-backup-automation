output "bucket_names" {
  description = "Map of category to bucket name."
  value       = { for k, b in aws_s3_bucket.backup_buckets : k => b.bucket }
}

output "bucket_arns" {
  description = "List of bucket ARNs."
  value       = [for b in aws_s3_bucket.backup_buckets : b.arn]
}
