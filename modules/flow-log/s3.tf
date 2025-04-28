module "centralize_flow_log_bucket" {
  source  = "oozou/s3/aws"
  version = "2.0.1"

  count = 1 - local.account_mode

  prefix      = var.prefix
  bucket_name = "account-flow-log"
  environment = "centralize"

  centralize_hub     = true
  versioning_enabled = true
  force_s3_destroy   = false

  is_enable_s3_hardening_policy      = false
  is_create_consumer_readonly_policy = true

  lifecycle_rules = var.centralize_flow_log_bucket_lifecycle_rule

  additional_bucket_polices = [
    data.aws_iam_policy_document.s3_flow_log[count.index].json,
    data.aws_iam_policy_document.force_ssl_s3_communication.json
  ]

  kms_key_arn = { kms_arn = local.is_create_flow_log_kms ? module.flow_log_kms[0].key_arn : var.kms_key_id }

  tags = var.tags
}
