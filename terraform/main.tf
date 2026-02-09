resource "aws_s3_bucket" "backup_bucket" {
  bucket = var.s3_bucket_name
  tags = {
    Name        = "S3 Backup Automation Bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.backup_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle_config" {
  bucket = aws_s3_bucket.backup_bucket.id

  rule {
    id     = "glacier_transition"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 365 # Delete objects after 365 days from GLACIER
    }
  }
}

resource "aws_iam_user" "s3_backup_user" {
  name = var.iam_user_name
  path = "/"
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "${var.iam_user_name}-s3-access-policy"
  description = "IAM policy for S3 backup user to access the backup bucket."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Effect   = "Allow"
        Resource = [
          aws_s3_bucket.backup_bucket.arn,
          "${aws_s3_bucket.backup_bucket.arn}/*"
        ]
      },
    ]
  })
}

resource "aws_iam_user_policy_attachment" "s3_access_attachment" {
  user       = aws_iam_user.s3_backup_user.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_access_key" "s3_backup_user_key" {
  user = aws_iam_user.s3_backup_user.name
}
