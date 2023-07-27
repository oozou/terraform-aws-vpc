/* -------------------------------------------------------------------------- */
/*                                   AWS_KMS                                  */
/* -------------------------------------------------------------------------- */
module "flow_log_kms" {
  source  = "oozou/kms-key/aws"
  version = "2.0.1"

  count = 1 - local.account_mode

  key_type    = "service"
  description = "Used to encrypt data for account centralize vpc flow log"
  prefix      = var.prefix
  name        = "account-flow-log"
  environment = "centralize"

  additional_policies = [data.aws_iam_policy_document.kms_flow_log[count.index].json]

  tags = var.tags
}
