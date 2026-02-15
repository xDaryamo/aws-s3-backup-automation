resource "aws_sns_topic" "backup_notifications" {
  name = "s3-backup-notifications"
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.backup_notifications.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
