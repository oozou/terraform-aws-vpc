module "flow_log" {
  source                          = "./modules/flow-log"
  vpc_id                          = try(aws_vpc.this[0].id, "")
  prefix                          = var.prefix
  environment                     = var.environment
  centralize_flow_log_bucket_name = var.centralize_flow_log_bucket_name
  kms_key_id                      = var.centrailize_flow_log_kms_key_id

  account_mode      = var.account_mode
  spoke_account_ids = var.spoke_account_ids

  centralize_flow_log_bucket_lifecycle_rule = var.centralize_flow_log_bucket_lifecycle_rule

  tags = var.tags
}
