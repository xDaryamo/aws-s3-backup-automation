variable "iam_user_name" {
  description = "Name for the IAM user."
  type        = string
}

variable "bucket_arns" {
  description = "List of bucket ARNs to grant access to."
  type        = list(string)
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic to grant publish access to."
  type        = string
}
