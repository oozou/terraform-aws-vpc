# Change Log

All notable changes to this module will be documented in this file.

## [1.1.6] - 2022-07-18

### Changed

- fix flow log policy to support all region

## [1.1.5] - 2022-06-30

### Added

- support kms, log retention for log group 

## [1.1.4] - 2022-06-15

### Changed

- change version of terraform-aws-kms from `v0.0.2` to `v1.0.0`
- change version of terraform-aws-s3 from `v1.0.2` to `v1.0.4`

## [1.1.2] - 2022-04-18

### Added

- support flow_log_s3_integration toggle mode

## [1.1.1] - 2022-03-17

### Changed

- flow log naming
- default value for variable `is_create_database_subnet_route_table` from `false` to `true`

## [1.1.10] - 2022-03-15

### Added

- naming resources
- support disable nat
- support subnet discovery for aws-loadbalancer-controller (eks)

### Changed

- move flow logs to sub-module

## [1.0.1] - 2022-02-23

### Added

- tags resources


## [1.0.0] - 2022-02-02

### Added

- init terraform-aws-vpc module
