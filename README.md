# AWS VPC Terraform Module

Terraform module with create vpc and subnet resources on AWS.

## Usage

```terraform
module "vpc" {
  source = "<source>"

  prefix      = "sbth"
  environment = "devops"

  #VPC
  cidr              = "10.0.0.0/16"
  public_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets   = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  database_subnets  = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
  availability_zone = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]

  is_create_nat_gateway        = true  # default false
  is_enable_single_nat_gateway = false # default false
  is_create_vpc_flow_logs      = true  # defautl false

  #VPC Flow logs
  account_mode = "hub"

  # centralize_flow_log_bucket_name = "test-bucket"
  # centrailize_flow_log_kms_key_id = "arn:aws:kms:ap-southeast-1:557291035693:key/9b55d572-037b-4a95-8bc3-4342a1e952a4"
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

  tags = {
    "Workspace" = "000-test"
  }
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
| <a name="provider_aws"></a> [aws](#provider_aws) | 4.4.0   |

## Modules

| Name                                                        | Source             | Version |
| ----------------------------------------------------------- | ------------------ | ------- |
| <a name="module_flow_log"></a> [flow_log](#module_flow_log) | ./modules/flow-log | n/a     |

## Resources

| Name                                                                                                                                              | Type     |
| ------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_default_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group)             | resource |
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)                                                    | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway)                         | resource |
| [aws_nat_gateway.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway)                                    | resource |
| [aws_route.database_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                               | resource |
| [aws_route.database_nat_gateway_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                          | resource |
| [aws_route.private_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                | resource |
| [aws_route.private_nat_gateway_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                           | resource |
| [aws_route.public_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                            | resource |
| [aws_route.public_internet_gateway_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                       | resource |
| [aws_route_table.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)                               | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)                                | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)                                 | resource |
| [aws_route_table_association.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)       | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)        | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)         | resource |
| [aws_subnet.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)                                         | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)                                          | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)                                           | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)                                                   | resource |
| [aws_vpc_dhcp_options.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options)                         | resource |
| [aws_vpc_dhcp_options_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options_association) | resource |

## Inputs

| Name                                                                                                                                                         | Description                                                                                                                                                                      | Type                                                                                                                                                                      | Default                                   | Required |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------- | :------: |
| <a name="input_account_mode"></a> [account_mode](#input_account_mode)                                                                                        | Account mode for provision cloudtrail, if account_mode is hub, will provision S3, KMS, CloudTrail. if account_mode is spoke, will provision only CloudTrail                      | `string`                                                                                                                                                                  | n/a                                       |   yes    |
| <a name="input_availability_zone"></a> [availability_zone](#input_availability_zone)                                                                         | A list of availability zones names or ids in the region                                                                                                                          | `list(string)`                                                                                                                                                            | n/a                                       |   yes    |
| <a name="input_centrailize_flow_log_kms_key_id"></a> [centrailize_flow_log_kms_key_id](#input_centrailize_flow_log_kms_key_id)                               | The ARN for the KMS encryption key. Leave this default if account_mode is hub. If account_mode is spoke, please provide centrailize kms key arn (hub).                           | `string`                                                                                                                                                                  | `""`                                      |    no    |
| <a name="input_centralize_flow_log_bucket_lifecycle_rule"></a> [centralize_flow_log_bucket_lifecycle_rule](#input_centralize_flow_log_bucket_lifecycle_rule) | List of lifecycle rules to transition the data. Leave empty to disable this feature. storage_class can be STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, GLACIER, or DEEP_ARCHIVE | <pre>list(object({<br> id = string<br><br> transition = list(object({<br> days = number<br> storage_class = string<br> }))<br><br> expiration_days = number<br> }))</pre> | `[]`                                      |    no    |
| <a name="input_centralize_flow_log_bucket_name"></a> [centralize_flow_log_bucket_name](#input_centralize_flow_log_bucket_name)                               | S3 bucket for store Cloudtrail log (long terms), leave this default if account_mode is hub. If account_mode is spoke, please provide centrailize flow log S3 bucket name (hub).  | `string`                                                                                                                                                                  | `""`                                      |    no    |
| <a name="input_cidr"></a> [cidr](#input_cidr)                                                                                                                | The CIDR block for the VPC                                                                                                                                                       | `string`                                                                                                                                                                  | n/a                                       |   yes    |
| <a name="input_database_subnets"></a> [database_subnets](#input_database_subnets)                                                                            | The CIDR block for the database subnets. Required 3 subnets for availability zones                                                                                               | `list(string)`                                                                                                                                                            | `[]`                                      |    no    |
| <a name="input_dhcp_options_domain_name"></a> [dhcp_options_domain_name](#input_dhcp_options_domain_name)                                                    | Specifies DNS name for DHCP options set (requires enable_dhcp_options set to true)                                                                                               | `string`                                                                                                                                                                  | `""`                                      |    no    |
| <a name="input_dhcp_options_domain_name_servers"></a> [dhcp_options_domain_name_servers](#input_dhcp_options_domain_name_servers)                            | Specify a list of DNS server addresses for DHCP options set, default to AWS provided (requires enable_dhcp_options set to true)                                                  | `list(string)`                                                                                                                                                            | <pre>[<br> "AmazonProvidedDNS"<br>]</pre> |    no    |
| <a name="input_dhcp_options_netbios_name_servers"></a> [dhcp_options_netbios_name_servers](#input_dhcp_options_netbios_name_servers)                         | Specify a list of netbios servers for DHCP options set (requires enable_dhcp_options set to true)                                                                                | `list(string)`                                                                                                                                                            | `[]`                                      |    no    |
| <a name="input_dhcp_options_netbios_node_type"></a> [dhcp_options_netbios_node_type](#input_dhcp_options_netbios_node_type)                                  | Specify netbios node_type for DHCP options set (requires enable_dhcp_options set to true)                                                                                        | `string`                                                                                                                                                                  | `""`                                      |    no    |
| <a name="input_dhcp_options_ntp_servers"></a> [dhcp_options_ntp_servers](#input_dhcp_options_ntp_servers)                                                    | Specify a list of NTP servers for DHCP options set (requires enable_dhcp_options set to true)                                                                                    | `list(string)`                                                                                                                                                            | `[]`                                      |    no    |
| <a name="input_enable_classiclink"></a> [enable_classiclink](#input_enable_classiclink)                                                                      | Should be true to enable ClassicLink for the VPC. Only valid in regions and accounts that support EC2 Classic.                                                                   | `bool`                                                                                                                                                                    | `null`                                    |    no    |
| <a name="input_enable_classiclink_dns_support"></a> [enable_classiclink_dns_support](#input_enable_classiclink_dns_support)                                  | Should be true to enable ClassicLink DNS Support for the VPC. Only valid in regions and accounts that support EC2 Classic.                                                       | `bool`                                                                                                                                                                    | `null`                                    |    no    |
| <a name="input_enable_dhcp_options"></a> [enable_dhcp_options](#input_enable_dhcp_options)                                                                   | Should be true if you want to specify a DHCP options set with a custom domain name, DNS servers, NTP servers, netbios servers, and/or netbios server type                        | `bool`                                                                                                                                                                    | `false`                                   |    no    |
| <a name="input_enable_dns_hostnames"></a> [enable_dns_hostnames](#input_enable_dns_hostnames)                                                                | Should be true to enable DNS hostnames in the VPC                                                                                                                                | `bool`                                                                                                                                                                    | `false`                                   |    no    |
| <a name="input_enable_dns_support"></a> [enable_dns_support](#input_enable_dns_support)                                                                      | Should be true to enable DNS support in the VPC                                                                                                                                  | `bool`                                                                                                                                                                    | `true`                                    |    no    |
| <a name="input_enable_eks_auto_discovery"></a> [enable_eks_auto_discovery](#input_enable_eks_auto_discovery)                                                 | Tags public, private subnet to auto discovery                                                                                                                                    | `bool`                                                                                                                                                                    | `true`                                    |    no    |
| <a name="input_enable_ipv6"></a> [enable_ipv6](#input_enable_ipv6)                                                                                           | Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block.                   | `bool`                                                                                                                                                                    | `false`                                   |    no    |
| <a name="input_environment"></a> [environment](#input_environment)                                                                                           | Environment Variable used as a prefix                                                                                                                                            | `string`                                                                                                                                                                  | n/a                                       |   yes    |
| <a name="input_instance_tenancy"></a> [instance_tenancy](#input_instance_tenancy)                                                                            | A tenancy option for instances launched into the VPC                                                                                                                             | `string`                                                                                                                                                                  | `"default"`                               |    no    |
| <a name="input_is_create_database_subnet_route_table"></a> [is_create_database_subnet_route_table](#input_is_create_database_subnet_route_table)             | Whether to create database subnet or not                                                                                                                                         | `bool`                                                                                                                                                                    | `false`                                   |    no    |
| <a name="input_is_create_internet_gateway"></a> [is_create_internet_gateway](#input_is_create_internet_gateway)                                              | Whether to create igw or not                                                                                                                                                     | `bool`                                                                                                                                                                    | `true`                                    |    no    |
| <a name="input_is_create_nat_gateway"></a> [is_create_nat_gateway](#input_is_create_nat_gateway)                                                             | Whether to create nat gatewat or not                                                                                                                                             | `bool`                                                                                                                                                                    | `false`                                   |    no    |
| <a name="input_is_create_vpc"></a> [is_create_vpc](#input_is_create_vpc)                                                                                     | Whether to create vpc or not                                                                                                                                                     | `bool`                                                                                                                                                                    | `true`                                    |    no    |
| <a name="input_is_enable_single_nat_gateway"></a> [is_enable_single_nat_gateway](#input_is_enable_single_nat_gateway)                                        | Should be true if you want to provision a single shared NAT Gateway across all of your private networks                                                                          | `bool`                                                                                                                                                                    | `false`                                   |    no    |
| <a name="input_is_one_nat_gateway_per_az"></a> [is_one_nat_gateway_per_az](#input_is_one_nat_gateway_per_az)                                                 | Enable multiple Nat gateway and public subnets with Multi-AZ                                                                                                                     | `bool`                                                                                                                                                                    | `false`                                   |    no    |
| <a name="input_prefix"></a> [prefix](#input_prefix)                                                                                                          | The prefix name of customer to be displayed in AWS console and resource                                                                                                          | `string`                                                                                                                                                                  | n/a                                       |   yes    |
| <a name="input_private_subnets"></a> [private_subnets](#input_private_subnets)                                                                               | The CIDR block for the private subnets. Required 3 subnets for availability zones                                                                                                | `list(string)`                                                                                                                                                            | n/a                                       |   yes    |
| <a name="input_public_subnets"></a> [public_subnets](#input_public_subnets)                                                                                  | The CIDR block for the public subnets. Required 3 subnets for availability zones                                                                                                 | `list(string)`                                                                                                                                                            | n/a                                       |   yes    |
| <a name="input_spoke_account_ids"></a> [spoke_account_ids](#input_spoke_account_ids)                                                                         | Spoke account Ids, if mode is hub.                                                                                                                                               | `list(string)`                                                                                                                                                            | `[]`                                      |    no    |
| <a name="input_tags"></a> [tags](#input_tags)                                                                                                                | Tags to add more; default tags contian {terraform=true, environment=var.environment}                                                                                             | `map(string)`                                                                                                                                                             | `{}`                                      |    no    |

## Outputs

| Name                                                                                                                                   | Description                                                         |
| -------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| <a name="output_centralize_flow_log_bucket_arn"></a> [centralize_flow_log_bucket_arn](#output_centralize_flow_log_bucket_arn)          | S3 Centralize Flow log Bucket ARN                                   |
| <a name="output_centralize_flow_log_bucket_name"></a> [centralize_flow_log_bucket_name](#output_centralize_flow_log_bucket_name)       | S3 Centralize Flow log Bucket Name                                  |
| <a name="output_centralize_flow_log_key_arn"></a> [centralize_flow_log_key_arn](#output_centralize_flow_log_key_arn)                   | KMS Centralize Flow log key arn                                     |
| <a name="output_centralize_flow_log_key_id"></a> [centralize_flow_log_key_id](#output_centralize_flow_log_key_id)                      | KMS Centralize Flow log key id                                      |
| <a name="output_database_subnets_arns"></a> [database_subnets_arns](#output_database_subnets_arns)                                     | List of ARNs of database subnets                                    |
| <a name="output_database_subnets_cidr_blocks"></a> [database_subnets_cidr_blocks](#output_database_subnets_cidr_blocks)                | List of cidr_blocks of database subnets                             |
| <a name="output_database_subnets_ids"></a> [database_subnets_ids](#output_database_subnets_ids)                                        | List of IDs of database subnets                                     |
| <a name="output_database_subnets_ipv6_cidr_blocks"></a> [database_subnets_ipv6_cidr_blocks](#output_database_subnets_ipv6_cidr_blocks) | List of IPv6 cidr_blocks of database subnets in an IPv6 enabled VPC |
| <a name="output_default_security_gruop_id"></a> [default_security_gruop_id](#output_default_security_gruop_id)                         | The ID of the security group created by default on VPC creation     |
| <a name="output_flow_log_cloudwatch_dest_arn"></a> [flow_log_cloudwatch_dest_arn](#output_flow_log_cloudwatch_dest_arn)                | Flow log CloudWatch ARN                                             |
| <a name="output_flow_log_cloudwatch_dest_id"></a> [flow_log_cloudwatch_dest_id](#output_flow_log_cloudwatch_dest_id)                   | Flow log CloudWatch Id                                              |
| <a name="output_flow_log_s3_dest_arn"></a> [flow_log_s3_dest_arn](#output_flow_log_s3_dest_arn)                                        | Flow log S3 ARN                                                     |
| <a name="output_flow_log_s3_dest_id"></a> [flow_log_s3_dest_id](#output_flow_log_s3_dest_id)                                           | Flow log S3 Id                                                      |
| <a name="output_igw_arn"></a> [igw_arn](#output_igw_arn)                                                                               | The ARN of the Internet Gateway                                     |
| <a name="output_igw_id"></a> [igw_id](#output_igw_id)                                                                                  | The ARN of the Internet Gateway                                     |
| <a name="output_natgw_ids"></a> [natgw_ids](#output_natgw_ids)                                                                         | List of NAT Gateway IDs                                             |
| <a name="output_private_subnets_arns"></a> [private_subnets_arns](#output_private_subnets_arns)                                        | List of ARNs of private subnets                                     |
| <a name="output_private_subnets_cidrs_blocks"></a> [private_subnets_cidrs_blocks](#output_private_subnets_cidrs_blocks)                | List if cidr_blocks of private subnets                              |
| <a name="output_private_subnets_ids"></a> [private_subnets_ids](#output_private_subnets_ids)                                           | List of IDs of private subnets                                      |
| <a name="output_private_subnets_ipv6_cidr_blocks"></a> [private_subnets_ipv6_cidr_blocks](#output_private_subnets_ipv6_cidr_blocks)    | List of IPv6 cidr_blocks of private subnets in an IPv6 enabled VPC  |
| <a name="output_public_subnets_arns"></a> [public_subnets_arns](#output_public_subnets_arns)                                           | List of ARNs of public subnets                                      |
| <a name="output_public_subnets_cidrs_blocks"></a> [public_subnets_cidrs_blocks](#output_public_subnets_cidrs_blocks)                   | List if cidr_blocks of public subnets                               |
| <a name="output_public_subnets_ids"></a> [public_subnets_ids](#output_public_subnets_ids)                                              | List of IDs of public subnets                                       |
| <a name="output_public_subnets_ipv6_cidr_blocks"></a> [public_subnets_ipv6_cidr_blocks](#output_public_subnets_ipv6_cidr_blocks)       | List of IPv6 cidr_blocks of public subnets in an IPv6 enabled VPC   |
| <a name="output_vpc_arn"></a> [vpc_arn](#output_vpc_arn)                                                                               | The ARN of the VPC                                                  |
| <a name="output_vpc_cidr_block"></a> [vpc_cidr_block](#output_vpc_cidr_block)                                                          | The CIDR block of the VPC                                           |
| <a name="output_vpc_id"></a> [vpc_id](#output_vpc_id)                                                                                  | The ID of the VPC                                                   |

<!-- END_TF_DOCS -->
