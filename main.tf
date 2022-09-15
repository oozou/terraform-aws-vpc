/* -------------------------------------------------------------------------- */
/*                                     VPC                                    */
/* -------------------------------------------------------------------------- */
resource "aws_vpc" "this" {
  count = var.is_create_vpc ? 1 : 0

  cidr_block                       = var.cidr
  instance_tenancy                 = var.instance_tenancy
  enable_dns_hostnames             = var.is_enable_dns_hostnames
  enable_dns_support               = var.is_enable_dns_support
  assign_generated_ipv6_cidr_block = var.is_enable_ipv6

  tags = merge(
    local.tags,
    { "Name" = format("%s-vpc", local.name) }
  )
}

resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  count = var.is_create_vpc && var.secondary_cidr != "" ? 1 : 0

  vpc_id     = aws_vpc.this[0].id
  cidr_block = var.secondary_cidr
}

resource "aws_vpc_dhcp_options" "this" {
  count = var.is_enable_dhcp_options && var.is_create_vpc ? 1 : 0

  domain_name          = var.dhcp_options_domain_name
  domain_name_servers  = var.dhcp_options_domain_name_servers
  ntp_servers          = var.dhcp_options_ntp_servers
  netbios_name_servers = var.dhcp_options_netbios_name_servers
  netbios_node_type    = var.dhcp_options_netbios_node_type

  tags = merge(
    local.tags,
    { "Name" = format("%s-dhcp-options", local.name) }
  )
}

resource "aws_vpc_dhcp_options_association" "this" {
  count = var.is_enable_dhcp_options && var.is_create_vpc ? 1 : 0

  vpc_id          = aws_vpc.this[0].id
  dhcp_options_id = aws_vpc_dhcp_options.this[0].id
}

resource "aws_default_security_group" "this" {
  count = var.is_create_vpc ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    local.tags,
    { "Name" = format("%s-default-sg", local.name) }
  )
}
/* -------------------------------------------------------------------------- */
/*                              Internet Gateway                              */
/* -------------------------------------------------------------------------- */
resource "aws_internet_gateway" "this" {
  count = var.is_create_internet_gateway && var.is_create_vpc ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    local.tags,
    { "Name" = format("%s-internet-gateway", local.name) }
  )
}
/* -------------------------------------------------------------------------- */
/*                                   Subnets                                  */
/* -------------------------------------------------------------------------- */
/* ----------------------------- public subnets ----------------------------- */
resource "aws_subnet" "public" {
  count = var.is_create_vpc && length(var.public_subnets) > 0 && (false == var.is_one_nat_gateway_per_az || length(var.public_subnets) >= length(var.availability_zone)) ? length(var.public_subnets) : 0

  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = var.public_subnets[count.index]
  map_public_ip_on_launch = var.is_map_public_ip_on_launch_public_subnet

  # If create single public subnet, AWS will take care of availability zones
  availability_zone = element(var.availability_zone, count.index)

  tags = merge(
    local.tags,
    var.is_enable_eks_auto_discovery ? local.eks_lb_controller_public_tag : {},
    { "Name" = length(var.public_subnets) > 1 ? format("%s-public-%s-subnet", local.name, element(local.availability_zone_shorten, count.index)) : format("%s-public-subnet", local.name) }
  )
}
/* ----------------------------- private subnets ---------------------------- */
resource "aws_subnet" "private" {
  count = var.is_create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  vpc_id            = aws_vpc.this[0].id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = element(var.availability_zone, count.index)

  tags = merge(
    local.tags,
    var.is_enable_eks_auto_discovery ? local.eks_lb_controller_private_tag : {},
    { "Name" = length(var.private_subnets) > 1 ? format("%s-private-%s-subnet", local.name, element(local.availability_zone_shorten, count.index)) : format("%s-private-subnet", local.name) }
  )
}
/* ---------------------------- database subnets ---------------------------- */
resource "aws_subnet" "database" {
  count = var.is_create_vpc && length(var.database_subnets) > 0 ? length(var.database_subnets) : 0

  vpc_id            = aws_vpc.this[0].id
  cidr_block        = var.database_subnets[count.index]
  availability_zone = element(var.availability_zone, count.index)

  tags = merge(
    local.tags,
    { "Name" = length(var.database_subnets) > 1 ? format("%s-database-%s-subnet", local.name, element(local.availability_zone_shorten, count.index)) : format("%s-database-subnet", local.name) }
  )
}
/* ---------------------------- secondary subnets --------------------------- */
resource "aws_subnet" "secondary" {
  count = var.is_create_vpc && length(var.secondary_subnets) > 0 && var.secondary_cidr != "" ? length(var.secondary_subnets) : 0

  vpc_id            = aws_vpc.this[0].id
  cidr_block        = var.secondary_subnets[count.index]
  availability_zone = element(var.availability_zone, count.index)

  tags = merge(
    local.tags,
    var.is_enable_eks_auto_discovery ? local.eks_lb_controller_private_tag : {},
    { "Name" = length(var.secondary_subnets) > 1 ? format("%s-secondary-%s-subnet", local.name, element(local.availability_zone_shorten, count.index)) : format("%s-secondary-subnet", local.name) }
  )
}
/* -------------------------------------------------------------------------- */
/*                                     NAT                                    */
/* -------------------------------------------------------------------------- */
/* -------------------------------- Main Nat -------------------------------- */
resource "aws_eip" "nat" {
  count = var.is_create_vpc && var.is_create_nat_gateway ? local.nat_gateway_count : 0

  vpc = true

  tags = merge(
    local.tags,
    { "Name" = local.nat_gateway_count > 1 ? format("%s-eip-nat-%s", local.name, element(local.availability_zone_shorten, count.index)) : format("%s-eip-nat", local.name) }
  )
}

resource "aws_nat_gateway" "nat" {
  count = var.is_create_vpc && var.is_create_nat_gateway ? local.nat_gateway_count : 0

  depends_on = [aws_internet_gateway.this[0]]

  allocation_id = element(aws_eip.nat[*].id, var.is_enable_single_nat_gateway ? 0 : count.index)
  subnet_id     = element(aws_subnet.public[*].id, var.is_enable_single_nat_gateway ? 0 : count.index)

  tags = merge(
    local.tags,
    { "Name" = local.nat_gateway_count > 1 ? format("%s-nat-%s", local.name, element(local.availability_zone_shorten, count.index)) : format("%s-nat", local.name) }
  )
}
/* ------------------------------ Secondary NAT ----------------------------- */
resource "aws_nat_gateway" "secondary_nat" {
  count = var.is_create_vpc && length(var.secondary_subnets) > 0 && var.secondary_cidr != "" && var.is_create_secondary_nat_gateway ? local.nat_gateway_count : 0

  depends_on = [aws_internet_gateway.this[0]]

  subnet_id         = element(aws_subnet.private[*].id, var.is_enable_single_nat_gateway ? 0 : count.index)
  connectivity_type = "private"

  tags = merge(
    local.tags,
    { "Name" = local.nat_gateway_count > 1 ? format("%s-secondary-nat-%s", local.name, element(local.availability_zone_shorten, count.index)) : format("%s-secondary-nat", local.name) }
  )
}
/* -------------------------------------------------------------------------- */
/*                             Public Route Table                             */
/* -------------------------------------------------------------------------- */
/* ------------------------------- route table ------------------------------ */
resource "aws_route_table" "public" {
  count = var.is_create_vpc && length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    local.tags,
    { "Name" = format("%s-public-rtb", local.name) }
  )
}

resource "aws_route" "public_internet_gateway" {
  count = var.is_create_vpc && var.is_create_internet_gateway && length(var.public_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_route" "public_internet_gateway_ipv6" {
  count = var.is_create_vpc && var.is_create_internet_gateway && var.is_enable_ipv6 && length(var.public_subnets) > 0 ? 1 : 0

  route_table_id              = aws_route_table.public[0].id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.this[0].id
}
/* ---------------------------- route association --------------------------- */
resource "aws_route_table_association" "public" {
  count = var.is_create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public[0].id
}
/* -------------------------------------------------------------------------- */
/*                             Private Route Table                            */
/* -------------------------------------------------------------------------- */
/* ------------------------------- route table ------------------------------ */
resource "aws_route_table" "private" {
  count = var.is_create_vpc && length(var.private_subnets) > 0 ? local.nat_gateway_count : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    local.tags,
    { "Name" = local.nat_gateway_count > 1 ? format("%s-private-%s-rtb", local.name, element(local.availability_zone_shorten, count.index)) : format("%s-private-rtb", local.name) }
  )
}

resource "aws_route" "private_nat_gateway" {
  count = var.is_create_vpc && var.is_create_nat_gateway && length(var.private_subnets) > 0 ? local.nat_gateway_count : 0

  route_table_id         = element(aws_route_table.private[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat[*].id, count.index)

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "private_nat_gateway_ipv6" {
  count = var.is_create_vpc && var.is_create_nat_gateway && var.is_enable_ipv6 && length(var.private_subnets) > 0 ? local.nat_gateway_count : 0

  route_table_id              = element(aws_route_table.private[*].id, count.index)
  destination_ipv6_cidr_block = "::/0"
  nat_gateway_id              = element(aws_nat_gateway.nat[*].id, count.index)

  timeouts {
    create = "5m"
  }
}
/* ---------------------------- route association --------------------------- */
resource "aws_route_table_association" "private" {
  count = var.is_create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(aws_route_table.private[*].id, count.index)
}
/* -------------------------------------------------------------------------- */
/*                            Database Route Table                            */
/* -------------------------------------------------------------------------- */
/* ------------------------------- route table ------------------------------ */
resource "aws_route_table" "database" {
  count = var.is_create_vpc && var.is_create_database_subnet_route_table && length(var.database_subnets) > 0 && var.is_create_nat_gateway ? var.is_enable_single_nat_gateway ? 1 : length(var.database_subnets) : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    local.tags,
    { "Name" = local.nat_gateway_count > 1 ? format("%s-database-%s-rtb", local.name, element(local.availability_zone_shorten, count.index)) : format("%s-database-rtb", local.name) }
  )
}

resource "aws_route" "database_nat_gateway" {
  count = var.is_create_vpc && var.is_create_database_subnet_route_table && length(var.database_subnets) > 0 && var.is_create_nat_gateway ? var.is_enable_single_nat_gateway ? 1 : length(var.database_subnets) : 0

  route_table_id         = element(aws_route_table.database[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat[*].id, count.index)

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "database_nat_gateway_ipv6" {
  count = var.is_create_vpc && var.is_create_database_subnet_route_table && var.is_enable_ipv6 && length(var.database_subnets) > 0 && var.is_create_nat_gateway ? var.is_enable_single_nat_gateway ? 1 : length(var.database_subnets) : 0

  route_table_id              = element(aws_route_table.database[*].id, count.index)
  destination_ipv6_cidr_block = "::/0"
  nat_gateway_id              = element(aws_nat_gateway.nat[*].id, count.index)

  timeouts {
    create = "5m"
  }
}
/* ---------------------------- route association --------------------------- */
resource "aws_route_table_association" "database" {
  count = var.is_create_vpc && var.is_create_database_subnet_route_table && length(var.database_subnets) > 0 ? length(var.database_subnets) : 0

  subnet_id      = element(aws_subnet.database[*].id, count.index)
  route_table_id = element(aws_route_table.database[*].id, count.index)
}
/* -------------------------------------------------------------------------- */
/*                            Secondary Route Table                           */
/* -------------------------------------------------------------------------- */
/* ------------------------------- route table ------------------------------ */
resource "aws_route_table" "secondary" {
  count = var.is_create_vpc && length(var.secondary_subnets) > 0 && var.secondary_cidr != "" ? local.nat_gateway_count : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    local.tags,
    { "Name" = local.nat_gateway_count > 1 ? format("%s-secondary-%s-rtb", local.name, element(local.availability_zone_shorten, count.index)) : format("%s-secondary-rtb", local.name) }
  )
}

resource "aws_route" "secondary_nat_gateway" {
  count = var.is_create_vpc && var.is_create_secondary_nat_gateway && length(var.secondary_subnets) > 0 ? local.nat_gateway_count : 0

  route_table_id         = element(aws_route_table.secondary[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.secondary_nat[*].id, count.index)

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "secondary_nat_gateway_ipv6" {
  count = var.is_create_vpc && var.is_create_secondary_nat_gateway && var.is_enable_ipv6 && length(var.secondary_subnets) > 0 ? local.nat_gateway_count : 0

  route_table_id              = element(aws_route_table.secondary[*].id, count.index)
  destination_ipv6_cidr_block = "::/0"
  nat_gateway_id              = element(aws_nat_gateway.secondary_nat[*].id, count.index)

  timeouts {
    create = "5m"
  }
}
/* ---------------------------- route association --------------------------- */
resource "aws_route_table_association" "secondary" {
  count = var.is_create_vpc && length(var.secondary_subnets) > 0 ? length(var.secondary_subnets) : 0

  subnet_id      = element(aws_subnet.secondary[*].id, count.index)
  route_table_id = element(aws_route_table.secondary[*].id, count.index)
}
