# aws-terraform-flow-log

## Usage

```terraform
module "flow_log" {
  source                          = "./modules/flow-log"
  vpc_id                          = <vpc_id>
  prefix                          = <customer_name>
  environment                     = <environment>
  centralize_flow_log_bucket_name = var.centralize_flow_log_bucket_name #if account_mode is hub, leave this default. if account_mode is spoke, this is required.
  kms_key_id                      = var.centrailize_flow_log_kms_key_id #if account_mode is hub, leave this default. if account_mode is spoke, this is required.

  account_mode      = var.account_mode #hub or spoke
  spoke_account_ids = []

  centralize_flow_log_bucket_lifecycle_rule = [
    {
      id = "FlowLogLifecyclePolicy"
      transition = [
        {
          days          = 31
          storage_class = "STANDARD_IA"
        },
        {
          days          = 366
          storage_class = "GLACIER"
        }
      ]
      expiration_days = 3660
    }
  ]

  tags = var.tags
}
```

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version  |
| ------------------------------------------------------------------------ | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | >= 4.00  |

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | >= 4.00 |

## Modules

| Name                                                                                                              | Source                                         | Version |
| ----------------------------------------------------------------------------------------------------------------- | ---------------------------------------------- | ------- |
| <a name="module_centralize_flow_log_bucket"></a> [centralize_flow_log_bucket](#module_centralize_flow_log_bucket) | git@github.com:oozou/terraform-aws-s3          | v1.0.1  |
| <a name="module_flow_log_kms"></a> [flow_log_kms](#module_flow_log_kms)                                           | git@github.com:oozou/terraform-aws-kms-key.git | v0.0.2  |

## Resources

| Name                                                                                                                                       | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| [aws_cloudwatch_log_group.flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)      | resource    |
| [aws_flow_log.cloudwatch_dest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log)                       | resource    |
| [aws_flow_log.s3_dest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log)                               | resource    |
| [aws_iam_policy.flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                          | resource    |
| [aws_iam_role.flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                              | resource    |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)              | data source |
| [aws_iam_policy_document.kms_flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)  | data source |

## Inputs

| Name                                                                                                                                                         | Description                                                                                                                                                                      | Type                                                                                                                                                                      | Default | Required |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | :------: |
| <a name="input_account_mode"></a> [account_mode](#input_account_mode)                                                                                        | Account mode for provision cloudtrail, if account_mode is hub, will provision S3, KMS, CloudTrail. if account_mode is spoke, will provision only CloudTrail                      | `string`                                                                                                                                                                  | n/a     |   yes    |
| <a name="input_centralize_flow_log_bucket_lifecycle_rule"></a> [centralize_flow_log_bucket_lifecycle_rule](#input_centralize_flow_log_bucket_lifecycle_rule) | List of lifecycle rules to transition the data. Leave empty to disable this feature. storage_class can be STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, GLACIER, or DEEP_ARCHIVE | <pre>list(object({<br> id = string<br><br> transition = list(object({<br> days = number<br> storage_class = string<br> }))<br><br> expiration_days = number<br> }))</pre> | `[]`    |    no    |
| <a name="input_centralize_flow_log_bucket_name"></a> [centralize_flow_log_bucket_name](#input_centralize_flow_log_bucket_name)                               | S3 bucket for store Cloudtrail log (long terms), leave this default if account_mode is hub. If account_mode is spoke, please provide centrailize flow log S3 bucket name (hub).  | `string`                                                                                                                                                                  | `""`    |    no    |
| <a name="input_environment"></a> [environment](#input_environment)                                                                                           | Environment name used as environment resources name.                                                                                                                             | `string`                                                                                                                                                                  | n/a     |   yes    |
| <a name="input_flow_log_retention_in_days"></a> [flow_log_retention_in_days](#input_flow_log_retention_in_days)                                              | Specifies the number of days you want to retain log events in the specified log group for VPC flow logs.                                                                         | `number`                                                                                                                                                                  | `90`    |    no    |
| <a name="input_is_create_flow_log"></a> [is_create_flow_log](#input_is_create_flow_log)                                                                      | Whether to create flow log.                                                                                                                                                      | `bool`                                                                                                                                                                    | `true`  |    no    |
| <a name="input_is_enable_flow_log_s3_integration"></a> [is_enable_flow_log_s3_integration](#input_is_enable_flow_log_s3_integration)                         | Whether to enable flow log S3 integration.                                                                                                                                       | `bool`                                                                                                                                                                    | `true`  |    no    |
| <a name="input_kms_key_id"></a> [kms_key_id](#input_kms_key_id)                                                                                              | The ARN for the KMS encryption key. Leave this default if account_mode is hub. If account_mode is spoke, please provide centrailize kms key arn (hub).                           | `string`                                                                                                                                                                  | `""`    |    no    |
| <a name="input_prefix"></a> [prefix](#input_prefix)                                                                                                          | The prefix name of customer to be displayed in AWS console and resource                                                                                                          | `string`                                                                                                                                                                  | n/a     |   yes    |
| <a name="input_spoke_account_ids"></a> [spoke_account_ids](#input_spoke_account_ids)                                                                         | Spoke account Ids, if mode is hub.                                                                                                                                               | `list(string)`                                                                                                                                                            | `[]`    |    no    |
| <a name="input_tags"></a> [tags](#input_tags)                                                                                                                | Tags to add more; default tags contian {terraform=true, environment=var.environment}                                                                                             | `map(string)`                                                                                                                                                             | `{}`    |    no    |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id)                                                                                                          | Flow log will configure in this VPC.                                                                                                                                             | `string`                                                                                                                                                                  | n/a     |   yes    |

## Outputs

| Name                                                                                                                             | Description                        |
| -------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| <a name="output_centralize_flow_log_bucket_arn"></a> [centralize_flow_log_bucket_arn](#output_centralize_flow_log_bucket_arn)    | S3 Centralize Flow log Bucket ARN  |
| <a name="output_centralize_flow_log_bucket_name"></a> [centralize_flow_log_bucket_name](#output_centralize_flow_log_bucket_name) | S3 Centralize Flow log Bucket Name |
| <a name="output_centralize_flow_log_key_arn"></a> [centralize_flow_log_key_arn](#output_centralize_flow_log_key_arn)             | KMS Centralize Flow log key arn    |
| <a name="output_centralize_flow_log_key_id"></a> [centralize_flow_log_key_id](#output_centralize_flow_log_key_id)                | KMS Centralize Flow log key id     |
| <a name="output_flow_log_cloudwatch_dest_arn"></a> [flow_log_cloudwatch_dest_arn](#output_flow_log_cloudwatch_dest_arn)          | Flow log CloudWatch ARN            |
| <a name="output_flow_log_cloudwatch_dest_id"></a> [flow_log_cloudwatch_dest_id](#output_flow_log_cloudwatch_dest_id)             | Flow log CloudWatch Id             |
| <a name="output_flow_log_s3_dest_arn"></a> [flow_log_s3_dest_arn](#output_flow_log_s3_dest_arn)                                  | Flow log S3 ARN                    |
| <a name="output_flow_log_s3_dest_id"></a> [flow_log_s3_dest_id](#output_flow_log_s3_dest_id)                                     | Flow log S3 Id                     |

<!-- END_TF_DOCS -->
