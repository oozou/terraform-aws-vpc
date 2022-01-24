# ############################################################################
# Public Route
# ############################################################################
resource "aws_route_table" "public" {
  count = length(var.public_subnets) > 0 && length(var.public_subnets) <= 3 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name"        = format("${var.environment}-${var.name}-public%s", count.index),
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
  count = length(var.public_subnets) > 0 && length(var.public_subnets) <= 3 ? local.nat_gateway_no : 0

  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public[0].id
}

# ############################################################################
# Private Route
# ############################################################################
resource "aws_route_table" "private" {
  count = local.nat_gateway_no

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name"        = format("${var.environment}-${var.name}-private%s", count.index),
      "Environment" = var.environment,
      "Terraform"   = "true"
    },
    var.tags
  )
}

resource "aws_route" "private_nat_gateway" {
  count = local.nat_gateway_no

  route_table_id         = element(aws_route_table.private[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat[*].id, count.index)

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "private" {
  count = local.nat_gateway_no

  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(aws_route_table.private[*].id, count.index)
}

# ############################################################################
# Database Route
# ############################################################################
resource "aws_route_table" "database" {
  count = local.nat_gateway_no

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name"        = format("${var.environment}-${var.name}-database%s", count.index),
      "Environment" = var.environment,
      "Terraform"   = "true"
    },
    var.tags
  )
}


resource "aws_route" "database_nat_gateway" {
  count = local.nat_gateway_no

  route_table_id         = element(aws_route_table.private[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat[*].id, count.index)

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "database" {
  count = local.nat_gateway_no

  subnet_id      = element(aws_subnet.database[*].id, count.index)
  route_table_id = element(aws_route_table.database[*].id, count.index)
}
