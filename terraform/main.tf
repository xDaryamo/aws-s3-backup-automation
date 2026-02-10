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


resource "aws_sns_topic" "backup_notifications" {
  name = "s3-backup-notifications"
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.backup_notifications.arn
  protocol  = "email"
  endpoint  = var.alert_email
}


resource "aws_iam_user" "s3_backup_user" {
  name = var.iam_user_name
  path = "/"
}

resource "aws_iam_policy" "backup_policy" {
  name        = "${var.iam_user_name}-backup-policy"
  description = "IAM policy for S3 backup and SNS notifications."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = flatten([
          for b in aws_s3_bucket.backup_buckets : [b.arn, "${b.arn}/*"]
        ])
      },
      {
        Action = [
          "sns:Publish"
        ]
        Effect   = "Allow"
        Resource = aws_sns_topic.backup_notifications.arn
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "backup_attachment" {
  user       = aws_iam_user.s3_backup_user.name
  policy_arn = aws_iam_policy.backup_policy.arn
}

resource "aws_iam_access_key" "s3_backup_user_key" {
  user = aws_iam_user.s3_backup_user.name
}
