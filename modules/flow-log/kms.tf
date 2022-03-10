/* -------------------------------------------------------------------------- */
/*                                   AWS_KMS                                  */
/* -------------------------------------------------------------------------- */
module "flow_log_kms" {
  count = 1 - local.account_mode

  source      = "git@github.com:oozou/terraform-aws-kms-key.git?ref=v0.0.2"
  key_type    = "service"
  description = "Used to encrypt data for account centralize vpc flow log"
  prefix      = var.prefix
  name        = "account-flow-log"
  environment = "centralize"

  additional_policies = [data.aws_iam_policy_document.kms_flow_log[count.index].json]

  tags = var.tags
}