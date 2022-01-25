# ############################################################################
# Public Route
# ############################################################################
resource "aws_route_table" "public" {
  count = length(var.public_subnets) > 0 && length(var.public_subnets) <= 3 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name"        = "${var.environment}-${var.name}-public",
      "Environment" = var.environment,
      "Terraform"   = "true"
    },
    var.tags
  )
}

resource "aws_route" "public_internet_gateway" {
  count = length(var.public_subnets) > 0 && length(var.public_subnets) <= 3 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_route" "public_internet_gateway_ipv6" {
  count = var.enable_ipv6 && length(var.public_subnets) > 0 && length(var.public_subnets) <= 3 ? 1 : 0

  route_table_id              = aws_route_table.public[0].id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.this[0].id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets) > 0 && length(var.public_subnets) <= 3 ? length(var.public_subnets) : 0

  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public[0].id
}

# ############################################################################
# Private Route
# ############################################################################
resource "aws_route_table" "private" {
  count = length(var.private_subnets) > 0 && length(var.private_subnets) <= 3 ? local.nat_gateway_no : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name"        = local.nat_gateway_no > 1 ? format("${var.environment}-${var.name}-private-%s", count.index) : "${var.environment}-${var.name}-private",
      "Environment" = var.environment,
      "Terraform"   = "true"
    },
    var.tags
  )
}

resource "aws_route" "private_nat_gateway" {
  count = length(var.private_subnets) > 0 && length(var.private_subnets) <= 3 ? local.nat_gateway_no : 0

  route_table_id         = element(aws_route_table.private[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat[*].id, count.index)

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "private_nat_gateway_ipv6" {
  count = var.enable_ipv6 && length(var.private_subnets) > 0 && length(var.private_subnets) <= 3 ? local.nat_gateway_no : 0

  route_table_id              = element(aws_route_table.private[*].id, count.index)
  destination_ipv6_cidr_block = "::/0"
  nat_gateway_id              = element(aws_nat_gateway.nat[*].id, count.index)

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets) > 0 && length(var.private_subnets) <= 3 ? local.nat_gateway_no : 0

  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(aws_route_table.private[*].id, count.index)
}

# ############################################################################
# Database Route
# ############################################################################
resource "aws_route_table" "database" {
  count = length(var.database_subnets) > 0 && length(var.database_subnets) <= 3 ? local.nat_gateway_no : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name"        = local.nat_gateway_no > 1 ? format("${var.environment}-${var.name}-database-%s", count.index) : "${var.environment}-${var.name}-database",
      "Environment" = var.environment,
      "Terraform"   = "true"
    },
    var.tags
  )
}

resource "aws_route" "database_nat_gateway" {
  count = length(var.database_subnets) > 0 && length(var.database_subnets) <= 3 ? local.nat_gateway_no : 0

  route_table_id         = element(aws_route_table.database[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat[*].id, count.index)

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "database_nat_gateway_ipv6" {
  count = var.enable_ipv6 && length(var.database_subnets) > 0 && length(var.database_subnets) <= 3 ? local.nat_gateway_no : 0

  route_table_id              = element(aws_route_table.database[*].id, count.index)
  destination_ipv6_cidr_block = "::/0"
  nat_gateway_id              = element(aws_nat_gateway.nat[*].id, count.index)

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnets) > 0 && length(var.database_subnets) <= 3 ? length(var.database_subnets) : 0

  subnet_id      = element(aws_subnet.database[*].id, count.index)
  route_table_id = element(aws_route_table.database[*].id, count.index)
}
