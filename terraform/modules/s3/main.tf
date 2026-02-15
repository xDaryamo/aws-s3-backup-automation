resource "aws_s3_bucket" "backup_buckets" {
  for_each = toset(var.bucket_categories)
  bucket   = "${var.s3_bucket_prefix}-${each.value}"

  tags = {
    Name        = "S3 Backup - ${each.value}"
    Environment = "Dev"
    Category    = each.value
  }
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  for_each = aws_s3_bucket.backup_buckets
  bucket   = each.value.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle_config" {
  for_each = aws_s3_bucket.backup_buckets
  bucket   = each.value.id

  rule {
    id     = "archive_and_cleanup"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}
