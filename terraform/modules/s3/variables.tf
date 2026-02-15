variable "s3_bucket_prefix" {
  description = "Prefix for the S3 buckets."
  type        = string
}

variable "bucket_categories" {
  description = "List of bucket categories to create."
  type        = list(string)
}
