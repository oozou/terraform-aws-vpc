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

| Name                                                                      | Version  |
|---------------------------------------------------------------------------|----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                   | >= 4.00  |

## Providers

| Name                                              | Version |
|---------------------------------------------------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.31.0  |

## Modules

| Name                                                                                                                     | Source            | Version |
|--------------------------------------------------------------------------------------------------------------------------|-------------------|---------|
| <a name="module_centralize_flow_log_bucket"></a> [centralize\_flow\_log\_bucket](#module\_centralize\_flow\_log\_bucket) | oozou/s3/aws      | 1.1.3   |
| <a name="module_flow_log_kms"></a> [flow\_log\_kms](#module\_flow\_log\_kms)                                             | oozou/kms-key/aws | 1.0.0   |

## Resources

| Name                                                                                                                                                     | Type        |
|----------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [aws_cloudwatch_log_group.flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)                    | resource    |
| [aws_flow_log.cloudwatch_dest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log)                                     | resource    |
| [aws_flow_log.s3_dest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log)                                             | resource    |
| [aws_iam_policy.flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                        | resource    |
| [aws_iam_role.flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                            | resource    |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                            | data source |
| [aws_iam_policy_document.force_ssl_s3_communication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms_flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)               | data source |
| [aws_iam_policy_document.s3_flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                                                 | data source |

## Inputs

| Name                                                                                                                                                                    | Description                                                                                                                                                                           | Type                                                                                                                                                                                                      | Default | Required |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------|:--------:|
| <a name="input_account_mode"></a> [account\_mode](#input\_account\_mode)                                                                                                | Account mode for provision cloudtrail, if account\_mode is hub, will provision S3, KMS, CloudTrail. if account\_mode is spoke, will provision only CloudTrail                         | `string`                                                                                                                                                                                                  | n/a     |   yes    |
| <a name="input_centralize_flow_log_bucket_lifecycle_rule"></a> [centralize\_flow\_log\_bucket\_lifecycle\_rule](#input\_centralize\_flow\_log\_bucket\_lifecycle\_rule) | List of lifecycle rules to transition the data. Leave empty to disable this feature. storage\_class can be STANDARD\_IA, ONEZONE\_IA, INTELLIGENT\_TIERING, GLACIER, or DEEP\_ARCHIVE | <pre>list(object({<br>    id = string<br><br>    transition = list(object({<br>      days          = number<br>      storage_class = string<br>    }))<br><br>    expiration_days = number<br>  }))</pre> | `[]`    |    no    |
| <a name="input_centralize_flow_log_bucket_name"></a> [centralize\_flow\_log\_bucket\_name](#input\_centralize\_flow\_log\_bucket\_name)                                 | S3 bucket for store Cloudtrail log (long terms), leave this default if account\_mode is hub. If account\_mode is spoke, please provide centrailize flow log S3 bucket name (hub).     | `string`                                                                                                                                                                                                  | `""`    |    no    |
| <a name="input_cloudwatch_log_retention_in_days"></a> [cloudwatch\_log\_retention\_in\_days](#input\_cloudwatch\_log\_retention\_in\_days)                              | Retention day for cloudwatch log group                                                                                                                                                | `number`                                                                                                                                                                                                  | `90`    |    no    |
| <a name="input_environment"></a> [environment](#input\_environment)                                                                                                     | Environment name used as environment resources name.                                                                                                                                  | `string`                                                                                                                                                                                                  | n/a     |   yes    |
| <a name="input_is_create_flow_log"></a> [is\_create\_flow\_log](#input\_is\_create\_flow\_log)                                                                          | Whether to create flow log.                                                                                                                                                           | `bool`                                                                                                                                                                                                    | `true`  |    no    |
| <a name="input_is_enable_flow_log_s3_integration"></a> [is\_enable\_flow\_log\_s3\_integration](#input\_is\_enable\_flow\_log\_s3\_integration)                         | Whether to enable flow log S3 integration.                                                                                                                                            | `bool`                                                                                                                                                                                                    | `true`  |    no    |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id)                                                                                                    | The ARN for the KMS encryption key. Leave this default if account\_mode is hub. If account\_mode is spoke, please provide centrailize kms key arn (hub).                              | `string`                                                                                                                                                                                                  | `""`    |    no    |
| <a name="input_prefix"></a> [prefix](#input\_prefix)                                                                                                                    | The prefix name of customer to be displayed in AWS console and resource                                                                                                               | `string`                                                                                                                                                                                                  | n/a     |   yes    |
| <a name="input_spoke_account_ids"></a> [spoke\_account\_ids](#input\_spoke\_account\_ids)                                                                               | Spoke account Ids, if mode is hub.                                                                                                                                                    | `list(string)`                                                                                                                                                                                            | `[]`    |    no    |
| <a name="input_tags"></a> [tags](#input\_tags)                                                                                                                          | Tags to add more; default tags contian {terraform=true, environment=var.environment}                                                                                                  | `map(string)`                                                                                                                                                                                             | `{}`    |    no    |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id)                                                                                                                  | Flow log will configure in this VPC.                                                                                                                                                  | `string`                                                                                                                                                                                                  | n/a     |   yes    |

## Outputs

| Name                                                                                                                                      | Description                        |
|-------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------|
| <a name="output_centralize_flow_log_bucket_arn"></a> [centralize\_flow\_log\_bucket\_arn](#output\_centralize\_flow\_log\_bucket\_arn)    | S3 Centralize Flow log Bucket ARN  |
| <a name="output_centralize_flow_log_bucket_name"></a> [centralize\_flow\_log\_bucket\_name](#output\_centralize\_flow\_log\_bucket\_name) | S3 Centralize Flow log Bucket Name |
| <a name="output_centralize_flow_log_key_arn"></a> [centralize\_flow\_log\_key\_arn](#output\_centralize\_flow\_log\_key\_arn)             | KMS Centralize Flow log key arn    |
| <a name="output_centralize_flow_log_key_id"></a> [centralize\_flow\_log\_key\_id](#output\_centralize\_flow\_log\_key\_id)                | KMS Centralize Flow log key id     |
| <a name="output_flow_log_cloudwatch_dest_arn"></a> [flow\_log\_cloudwatch\_dest\_arn](#output\_flow\_log\_cloudwatch\_dest\_arn)          | Flow log CloudWatch ARN            |
| <a name="output_flow_log_cloudwatch_dest_id"></a> [flow\_log\_cloudwatch\_dest\_id](#output\_flow\_log\_cloudwatch\_dest\_id)             | Flow log CloudWatch Id             |
| <a name="output_flow_log_s3_dest_arn"></a> [flow\_log\_s3\_dest\_arn](#output\_flow\_log\_s3\_dest\_arn)                                  | Flow log S3 ARN                    |
| <a name="output_flow_log_s3_dest_id"></a> [flow\_log\_s3\_dest\_id](#output\_flow\_log\_s3\_dest\_id)                                     | Flow log S3 Id                     |
<!-- END_TF_DOCS -->
