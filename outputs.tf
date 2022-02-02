# ############################################################################
# VPC
# ############################################################################
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = aws_vpc.this.arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this[*].cidr_block
}

output "default_security_gruop_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = aws_default_security_group.this.id
}

# ############################################################################
# Internet Gateway
# ############################################################################
output "igw_id" {
  description = "The ARN of the Internet Gateway"
  value       = aws_internet_gateway.this[0].id
}

output "igw_arn" {
  description = "The ARN of the Internet Gateway"
  value       = aws_internet_gateway.this[*].arn
}

# ############################################################################
# NAT Gateway
# ############################################################################
output "natgw_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.nat[*].id
}

# ############################################################################
# Public Subnets
# ############################################################################
output "public_subnets_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "public_subnets_arns" {
  description = "List of ARNs of public subnets"
  value       = aws_subnet.public[*].arn
}

output "public_subnets_cidrs_blocks" {
  description = "List if cidr_blocks of public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "public_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of public subnets in an IPv6 enabled VPC"
  value       = aws_subnet.public[*].ipv6_cidr_block
}

# ############################################################################
# Private Subnets
# ############################################################################
output "private_subnets_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "private_subnets_arns" {
  description = "List of ARNs of private subnets"
  value       = aws_subnet.private[*].arn
}

output "private_subnets_cidrs_blocks" {
  description = "List if cidr_blocks of private subnets"
  value       = aws_subnet.private[*].cidr_block
}

output "private_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of private subnets in an IPv6 enabled VPC"
  value       = aws_subnet.private[*].ipv6_cidr_block
}

# ############################################################################
# Database Subnets
# ############################################################################
output "database_subnets_ids" {
  description = "List of IDs of database subnets"
  value       = aws_subnet.database[*].id
}

output "database_subnets_arns" {
  description = "List of ARNs of database subnets"
  value       = aws_subnet.database[*].arn
}

output "database_subnets_cidr_blocks" {
  description = "List of cidr_blocks of database subnets"
  value       = aws_subnet.database[*].cidr_block
}

output "database_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of database subnets in an IPv6 enabled VPC"
  value       = aws_subnet.database[*].ipv6_cidr_block
}
