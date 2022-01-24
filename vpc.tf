# VPC Options Set
resource "aws_vpc" "this" {
  cidr_block                       = var.cidr
  instance_tenancy                 = var.instance_tenancy
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  enable_classiclink               = var.enable_classiclink
  enable_classiclink_dns_support   = var.enable_classiclink_dns_support
  assign_generated_ipv6_cidr_block = var.enable_ipv6

  tags = merge(
    {
      "Name"        = "${var.environment}-${var.name}-vpc",
      "Environment" = var.environment
    },
    var.tags
  )
}

# DHCP Options Set
resource "aws_vpc_dhcp_options" "this" {
  domain_name          = var.dhcp_options_domain_name
  domain_name_servers  = var.dhcp_options_domain_name_servers
  ntp_servers          = var.dhcp_options_ntp_servers
  netbios_name_servers = var.dhcp_options_netbios_name_servers
  netbios_node_type    = var.dhcp_options_netbios_node_type

  tags = merge(
    {
      "Name"        = "${var.environment}-${var.name}-dhcp-options",
      "Environment" = var.environment
    },
    var.tags
  )
}

resource "aws_vpc_dhcp_options_association" "this" {
  vpc_id          = aws_vpc.this.id
  dhcp_options_id = aws_vpc_dhcp_options.this.id
}

# Security Groups
resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name"        = "${var.environment}-${var.name}-default-sg",
      "Environment" = var.environment
    },
    var.tags
  )
}
