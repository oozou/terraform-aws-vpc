output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = module.vpc.vpc_arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

output "database_subnet_ids" {
  description = "List of IDs of database subnets"
  value       = module.vpc.database_subnet_ids
}

output "secondary_subnet_ids" {
  description = "List of IDs of secondary subnets"
  value       = module.vpc.secondary_subnet_ids
}

output "natgw_ids" {
  description = "List of NAT Gateway IDs"
  value       = module.vpc.natgw_ids
}

output "secondary_natgw_ids" {
  description = "List of Secondary NAT Gateway IDs"
  value       = module.vpc.secondary_natgw_ids
}

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = module.vpc.igw_id
}

output "flow_log_cloudwatch_dest_id" {
  description = "Flow log CloudWatch Id"
  value       = module.vpc.flow_log_cloudwatch_dest_id
}

output "flow_log_s3_dest_id" {
  description = "Flow log S3 Id"
  value       = module.vpc.flow_log_s3_dest_id
}

output "centralize_flow_log_bucket_name" {
  description = "S3 Centralize Flow log Bucket Name"
  value       = module.vpc.centralize_flow_log_bucket_name
}

output "route_table_public_id" {
  description = "Route table public id"
  value       = module.vpc.route_table_public_id
}

output "route_table_private_id" {
  description = "Route table private id"
  value       = module.vpc.route_table_private_id
}

output "route_table_database_id" {
  description = "Route table database id"
  value       = module.vpc.route_table_database_id
}
