/* -------------------------------------------------------------------------- */
/*                                   AWS_KMS                                  */
/* -------------------------------------------------------------------------- */
module "flow_log_kms" {
  source  = "oozou/kms-key/aws"
  version = "2.0.1"

  count = local.is_create_flow_log_kms ? 1 : 0

  key_type    = "service"
  description = "Used to encrypt data for account centralize vpc flow log"
  prefix      = var.prefix
  name        = "account-flow-log"
  environment = "centralize"

  additional_policies = [data.aws_iam_policy_document.kms_flow_log[count.index].json]

  tags = var.tags
}
