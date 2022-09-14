<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_tags"></a> [custom\_tags](#input\_custom\_tags) | Custom tags which can be passed on to the AWS resources. They should be key value pairs having distinct keys. | `map(string)` | `{}` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | [Required] Name prefix used for resource naming in this component | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | [Required] Name prefix used for resource naming in this component | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
