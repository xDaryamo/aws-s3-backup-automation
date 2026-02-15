module "s3" {
  source = "./modules/s3"

  s3_bucket_prefix  = var.s3_bucket_prefix
  bucket_categories = var.bucket_categories
}

module "sns" {
  source = "./modules/sns"

  alert_email = var.alert_email
}

module "iam" {
  source = "./modules/iam"

  iam_user_name = var.iam_user_name
  bucket_arns   = module.s3.bucket_arns
  sns_topic_arn = module.sns.topic_arn
}
