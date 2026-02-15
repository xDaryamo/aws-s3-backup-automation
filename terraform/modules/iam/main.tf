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
          for arn in var.bucket_arns : [arn, "${arn}/*"]
        ])
      },
      {
        Action = [
          "sns:Publish"
        ]
        Effect   = "Allow"
        Resource = var.sns_topic_arn
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
