# AWS VPC Terraform Module

Terraform module with create vpc and subnet resources on AWS.

## Usage

```terraform
module "vpc" {
  source = "git@git@github.com:oozou/terraform-aws-vpc.git?ref=v1.0.0"

  environment = "dev"
  name = "customer-corp"
  cidr = "10.0.0.0/16"

  high_availability_mode = true

  azs = ["ap-southeas-1a", "ap-southeast-1b", "ap-southeast-1c"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.101.0/23" ,"10.0.103.0/23", "10.0.105.0/23"]
  database_subnets = ["10.0.201.0/23", "10.0.203.0/23", "10.0.205.0/23"]

  tags = {
    "Custom-Tag" = "1"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.63 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.72.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.vpc_flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_default_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_flow_log.vpc_flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_iam_role.vpc_flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.vpc_flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.database_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.private_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_internet_gateway_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_dhcp_options.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options) | resource |
| [aws_vpc_dhcp_options_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options_association) | resource |
| [aws_iam_policy_document.vpc_flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.vpc_flow_log_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account"></a> [aws\_account](#input\_aws\_account) | AWS account credentials to access AWS | `map(string)` | n/a | yes |
| <a name="input_azs"></a> [azs](#input\_azs) | A list of availability zones names or ids in the region | `list(string)` | <pre>[<br>  "ap-southeast-1a",<br>  "ap-southeast-1b",<br>  "ap-southeast-1c"<br>]</pre> | no |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | The CIDR block for the VPC | `string` | n/a | yes |
| <a name="input_database_subnets"></a> [database\_subnets](#input\_database\_subnets) | The CIDR block for the database subnets. Required 3 subnets for availability zones | `list(string)` | n/a | yes |
| <a name="input_dhcp_options_domain_name"></a> [dhcp\_options\_domain\_name](#input\_dhcp\_options\_domain\_name) | Specifies DNS name for DHCP options set (requires enable\_dhcp\_options set to true) | `string` | `""` | no |
| <a name="input_dhcp_options_domain_name_servers"></a> [dhcp\_options\_domain\_name\_servers](#input\_dhcp\_options\_domain\_name\_servers) | Specify a list of DNS server addresses for DHCP options set, default to AWS provided (requires enable\_dhcp\_options set to true) | `list(string)` | <pre>[<br>  "AmazonProvidedDNS"<br>]</pre> | no |
| <a name="input_dhcp_options_netbios_name_servers"></a> [dhcp\_options\_netbios\_name\_servers](#input\_dhcp\_options\_netbios\_name\_servers) | Specify a list of netbios servers for DHCP options set (requires enable\_dhcp\_options set to true) | `list(string)` | `[]` | no |
| <a name="input_dhcp_options_netbios_node_type"></a> [dhcp\_options\_netbios\_node\_type](#input\_dhcp\_options\_netbios\_node\_type) | Specify netbios node\_type for DHCP options set (requires enable\_dhcp\_options set to true) | `string` | `""` | no |
| <a name="input_dhcp_options_ntp_servers"></a> [dhcp\_options\_ntp\_servers](#input\_dhcp\_options\_ntp\_servers) | Specify a list of NTP servers for DHCP options set (requires enable\_dhcp\_options set to true) | `list(string)` | `[]` | no |
| <a name="input_enable_classiclink"></a> [enable\_classiclink](#input\_enable\_classiclink) | Should be true to enable ClassicLink for the VPC. Only valid in regions and accounts that support EC2 Classic. | `bool` | `null` | no |
| <a name="input_enable_classiclink_dns_support"></a> [enable\_classiclink\_dns\_support](#input\_enable\_classiclink\_dns\_support) | Should be true to enable ClassicLink DNS Support for the VPC. Only valid in regions and accounts that support EC2 Classic. | `bool` | `null` | no |
| <a name="input_enable_dhcp_options"></a> [enable\_dhcp\_options](#input\_enable\_dhcp\_options) | Should be true if you want to specify a DHCP options set with a custom domain name, DNS servers, NTP servers, netbios servers, and/or netbios server type | `bool` | `false` | no |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | Should be true to enable DNS hostnames in the VPC | `bool` | `false` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | Should be true to enable DNS support in the VPC | `bool` | `true` | no |
| <a name="input_enable_ipv6"></a> [enable\_ipv6](#input\_enable\_ipv6) | Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | To manage a resources with tags | `string` | n/a | yes |
| <a name="input_flow_log_retention_in_days"></a> [flow\_log\_retention\_in\_days](#input\_flow\_log\_retention\_in\_days) | Specifies the number of days you want to retain log events in the specified log group for VPC flow logs. | `number` | `90` | no |
| <a name="input_high_availability_mode"></a> [high\_availability\_mode](#input\_high\_availability\_mode) | Enable multiple Nat gateway and public subnets with Multi-AZ | `bool` | `true` | no |
| <a name="input_instance_tenancy"></a> [instance\_tenancy](#input\_instance\_tenancy) | A tenancy option for instances launched into the VPC | `string` | `"default"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be used on all resource as indentifier | `string` | `""` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | The CIDR block for the private subnets. Required 3 subnets for availability zones | `list(string)` | n/a | yes |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | The CIDR block for the public subnets. Required 3 subnets for availability zones | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tag for a resource taht create by this component | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_subnets_arns"></a> [database\_subnets\_arns](#output\_database\_subnets\_arns) | List of ARNs of database subnets |
| <a name="output_database_subnets_cidr_blocks"></a> [database\_subnets\_cidr\_blocks](#output\_database\_subnets\_cidr\_blocks) | List of cidr\_blocks of database subnets |
| <a name="output_database_subnets_ids"></a> [database\_subnets\_ids](#output\_database\_subnets\_ids) | List of IDs of database subnets |
| <a name="output_database_subnets_ipv6_cidr_blocks"></a> [database\_subnets\_ipv6\_cidr\_blocks](#output\_database\_subnets\_ipv6\_cidr\_blocks) | List of IPv6 cidr\_blocks of database subnets in an IPv6 enabled VPC |
| <a name="output_default_security_gruop_id"></a> [default\_security\_gruop\_id](#output\_default\_security\_gruop\_id) | The ID of the security group created by default on VPC creation |
| <a name="output_igw_arn"></a> [igw\_arn](#output\_igw\_arn) | The ARN of the Internet Gateway |
| <a name="output_igw_id"></a> [igw\_id](#output\_igw\_id) | The ARN of the Internet Gateway |
| <a name="output_natgw_ids"></a> [natgw\_ids](#output\_natgw\_ids) | List of NAT Gateway IDs |
| <a name="output_netgw_arns"></a> [netgw\_arns](#output\_netgw\_arns) | The ARN of the Internet Gateway |
| <a name="output_private_subnets_arns"></a> [private\_subnets\_arns](#output\_private\_subnets\_arns) | List of ARNs of private subnets |
| <a name="output_private_subnets_cidrs_blocks"></a> [private\_subnets\_cidrs\_blocks](#output\_private\_subnets\_cidrs\_blocks) | List if cidr\_blocks of private subnets |
| <a name="output_private_subnets_ids"></a> [private\_subnets\_ids](#output\_private\_subnets\_ids) | List of IDs of private subnets |
| <a name="output_private_subnets_ipv6_cidr_blocks"></a> [private\_subnets\_ipv6\_cidr\_blocks](#output\_private\_subnets\_ipv6\_cidr\_blocks) | List of IPv6 cidr\_blocks of private subnets in an IPv6 enabled VPC |
| <a name="output_public_subnets_arns"></a> [public\_subnets\_arns](#output\_public\_subnets\_arns) | List of ARNs of public subnets |
| <a name="output_public_subnets_cidrs_blocks"></a> [public\_subnets\_cidrs\_blocks](#output\_public\_subnets\_cidrs\_blocks) | List if cidr\_blocks of public subnets |
| <a name="output_public_subnets_ids"></a> [public\_subnets\_ids](#output\_public\_subnets\_ids) | List of IDs of public subnets |
| <a name="output_public_subnets_ipv6_cidr_blocks"></a> [public\_subnets\_ipv6\_cidr\_blocks](#output\_public\_subnets\_ipv6\_cidr\_blocks) | List of IPv6 cidr\_blocks of public subnets in an IPv6 enabled VPC |
| <a name="output_vpc_arn"></a> [vpc\_arn](#output\_vpc\_arn) | The ARN of the VPC |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The CIDR block of the VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
