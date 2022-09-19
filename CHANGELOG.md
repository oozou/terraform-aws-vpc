# Change Log

All notable changes to this module will be documented in this file.

## [v1.2.1] - 2022-09-19

### Changed

- Flowlog to use Public modules

## [v1.2.0] - 2022-09-15

### Added

- Add resource `aws_vpc_ipv4_cidr_block_association.secondary_cidr` to associate vpc with second CIDR using for application
- Add resource `aws_subnet.secondary`
- Add resource `aws_nat_gateway.secondary_nat` as private connection in private subnet
- Add resource `aws_route_table.secondary` for secondary subnet
- Add resource `aws_route.secondary_nat_gateway` for secondary CIDR to use NAT as default route
- Add resource `aws_route.secondary_nat_gateway_ipv6` for secondary CIDR to use NAT as default route (IPv6)
- Add resource `aws_route_table_association.secondary` to associate route table with subnet
- Add output `secondary_vpc_cidr_block`
- Add output `secondary_natgw_ids`
- Add output `secondary_subnet_ids`
- Add output `secondary_subnet_arns`
- Add output `secondary_subnet_cidrs_blocks`
- Add output `secondary_subnet_ipv6_cidr_blocks`
- Add variable `var.secondary_cidr`
- Add variable `var.secondary_subnets`
- Add variable `var.is_create_secondary_nat_gateway` to allow non-nat creation
- Add secondary cidr `./examples/secondary-cidr`

### Changed

- Update description for variable `var.public_subnets`
- Update description for variable `var.private_subnets`
- Update description for variable `var.database_subnets`
- Update file `.gitignore`

### Removed

- Remove variable `var.enable_classiclink` due to deprecation
- Remove variable `var.is_enable_classiclink_dns_support` due to deprecation

## [v1.1.7] - 2022-07-27

### Changed

- Add local `policy_identifiers` inside sub module to generate identifiers for all account
- Update KMS policies for aws service with sid `Allow AWS Services to use the key`
- In DenyNonSSLRequests policies inside sub module, we update to `<s3_arn>` and `<s3_arn>/*` for best practice when hardening policies enable.
- Update module `centralize_flow_log_bucket` inside sub module from version v1.1.1 to v1.1.2

## [v1.1.6] - 2022-07-18

### Changed

- fix flow log policy to support all region

## [v1.1.5] - 2022-06-30

### Added

- support kms, log retention for log group 

## [v1.1.4] - 2022-06-15

### Changed

- change version of terraform-aws-kms from `v0.0.2` to `v1.0.0`
- change version of terraform-aws-s3 from `v1.0.2` to `v1.0.4`

## [v1.1.2] - 2022-04-18

### Added

- support flow_log_s3_integration toggle mode

## [v1.1.1] - 2022-03-17

### Changed

- flow log naming
- default value for variable `is_create_database_subnet_route_table` from `false` to `true`

## [v1.1.10] - 2022-03-15

### Added

- naming resources
- support disable nat
- support subnet discovery for aws-loadbalancer-controller (eks)

### Changed

- move flow logs to sub-module

## [v1.0.1] - 2022-02-23

### Added

- tags resources


## [v1.0.0] - 2022-02-02

### Added

- init terraform-aws-vpc module
