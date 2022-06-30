module "flow_log" {
  source                          = "./modules/flow-log"
  vpc_id                          = try(aws_vpc.this[0].id, "")
  prefix                          = var.prefix
  environment                     = var.environment
  centralize_flow_log_bucket_name = var.centralize_flow_log_bucket_name
  kms_key_id                      = var.centralize_flow_log_kms_key_id

  is_create_flow_log                = var.is_create_flow_log
  is_enable_flow_log_s3_integration = var.is_enable_flow_log_s3_integration
  cloudwatch_log_retention_in_days  = var.flow_log_retention_in_days

  account_mode      = var.account_mode
  spoke_account_ids = var.spoke_account_ids

  centralize_flow_log_bucket_lifecycle_rule = var.centralize_flow_log_bucket_lifecycle_rule

  tags = var.tags
}
