/* -------------------------------------------------------------------------- */
/*                                     VPC                                    */
/* -------------------------------------------------------------------------- */
output "vpc_id" {
  description = "The ID of the VPC"
  value       = try(aws_vpc.this[0].id, "")
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = try(aws_vpc.this[0].arn, "")
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this[*].cidr_block
}

output "secondary_vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc_ipv4_cidr_block_association.secondary_cidr[*].cidr_block
}

output "default_security_gruop_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = try(aws_default_security_group.this[0].id, "")
}

/* -------------------------------------------------------------------------- */
/*                              Internet Gateway                              */
/* -------------------------------------------------------------------------- */
output "igw_id" {
  description = "The ARN of the Internet Gateway"
  value       = try(aws_internet_gateway.this[0].id, "")
}

output "igw_arn" {
  description = "The ARN of the Internet Gateway"
  value       = try(aws_internet_gateway.this[0].arn, "")
}

/* -------------------------------------------------------------------------- */
/*                                 NAT Gateway                                */
/* -------------------------------------------------------------------------- */
output "natgw_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.nat[*].id
}

output "secondary_natgw_ids" {
  description = "List of Secondary NAT Gateway IDs"
  value       = aws_nat_gateway.secondary_nat[*].id
}

/* -------------------------------------------------------------------------- */
/*                               Public Subnets                               */
/* -------------------------------------------------------------------------- */
output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "public_subnet_arns" {
  description = "List of ARNs of public subnets"
  value       = aws_subnet.public[*].arn
}

output "public_subnet_cidrs_blocks" {
  description = "List if cidr_blocks of public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "public_subnet_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of public subnets in an IPv6 enabled VPC"
  value       = aws_subnet.public[*].ipv6_cidr_block
}
/* -------------------------------------------------------------------------- */
/*                               Private Subnets                              */
/* -------------------------------------------------------------------------- */
output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "private_subnet_arns" {
  description = "List of ARNs of private subnets"
  value       = aws_subnet.private[*].arn
}

output "private_subnet_cidrs_blocks" {
  description = "List if cidr_blocks of private subnets"
  value       = aws_subnet.private[*].cidr_block
}

output "private_subnet_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of private subnets in an IPv6 enabled VPC"
  value       = aws_subnet.private[*].ipv6_cidr_block
}

/* -------------------------------------------------------------------------- */
/*                              Database Subnets                              */
/* -------------------------------------------------------------------------- */
output "database_subnet_ids" {
  description = "List of IDs of database subnets"
  value       = aws_subnet.database[*].id
}

output "database_subnet_arns" {
  description = "List of ARNs of database subnets"
  value       = aws_subnet.database[*].arn
}

output "database_subnet_cidr_blocks" {
  description = "List of cidr_blocks of database subnets"
  value       = aws_subnet.database[*].cidr_block
}

output "database_subnet_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of database subnets in an IPv6 enabled VPC"
  value       = aws_subnet.database[*].ipv6_cidr_block
}

/* -------------------------------------------------------------------------- */
/*                              Secondary Subnets                             */
/* -------------------------------------------------------------------------- */
output "secondary_subnet_ids" {
  description = "List of IDs of secondary subnets"
  value       = aws_subnet.secondary[*].id
}

output "secondary_subnet_arns" {
  description = "List of ARNs of secondary subnets"
  value       = aws_subnet.secondary[*].arn
}

output "secondary_subnet_cidrs_blocks" {
  description = "List if cidr_blocks of secondary subnets"
  value       = aws_subnet.secondary[*].cidr_block
}

output "secondary_subnet_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of secondary subnets in an IPv6 enabled VPC"
  value       = aws_subnet.secondary[*].ipv6_cidr_block
}

/* -------------------------------------------------------------------------- */
/*                                  Flow Logs                                 */
/* -------------------------------------------------------------------------- */
output "flow_log_cloudwatch_dest_id" {
  description = "Flow log CloudWatch Id"
  value       = try(module.flow_log.flow_log_cloudwatch_dest_id, "")
}

output "flow_log_cloudwatch_dest_arn" {
  description = "Flow log CloudWatch ARN"
  value       = try(module.flow_log.flow_log_cloudwatch_dest_arn, "")
}

output "flow_log_s3_dest_id" {
  description = "Flow log S3 Id"
  value       = try(module.flow_log.flow_log_s3_dest_id, "")
}

output "flow_log_s3_dest_arn" {
  description = "Flow log S3 ARN"
  value       = try(module.flow_log.flow_log_s3_dest_arn, "")
}

output "centralize_flow_log_bucket_name" {
  description = "S3 Centralize Flow log Bucket Name"
  value       = try(module.flow_log.centralize_flow_log_bucket_name, "")
}

output "centralize_flow_log_bucket_arn" {
  description = "S3 Centralize Flow log Bucket ARN"
  value       = try(module.flow_log.centralize_flow_log_bucket_arn, "")
}

output "centralize_flow_log_key_arn" {
  description = "KMS Centralize Flow log key arn"
  value       = try(module.flow_log.centralize_flow_log_key_arn, "")
}

output "centralize_flow_log_key_id" {
  description = "KMS Centralize Flow log key id"
  value       = try(module.flow_log.centralize_flow_log_key_id, "")
}

output "flow_log_cloudwatch_log_group_name" {
  description = "Flow log CloudWatch Log Group Name"
  value       = try(module.flow_log.flow_log_cloudwatch_log_group_name, "")
}

output "flow_log_cloudwatch_log_group_arn" {
  description = "Flow log CloudWatch Log Group ARN"
  value       = try(module.flow_log.flow_log_cloudwatch_log_group_arn, "")
}
/* -------------------------------------------------------------------------- */
/*                                 Route Table                                */
/* -------------------------------------------------------------------------- */

output "route_table_public_id" {
  description = "Route table public id"
  value       = try(aws_route_table.public[0].id, "")
}

output "route_table_private_id" {
  description = "Route table private id"
  value       = try(aws_route_table.private[0].id, "")
}

output "route_table_database_id" {
  description = "Route table database id"
  value       = try(aws_route_table.database[0].id, "")
}
