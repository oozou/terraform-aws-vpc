module "centralize_flow_log_bucket" {
  count   = 1 - local.account_mode
  source  = "oozou/s3/aws"
  version = "1.1.2"


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

  kms_key_arn = { kms_arn = join("", module.flow_log_kms[*].key_arn) }

  tags = var.tags
}
