# ############################################################################
# Public Subnets
# ############################################################################
resource "aws_subnet" "public" {
  count = length(var.public_subnets) > 0 && length(var.public_subnets) <= 3 ? local.nat_gateway_no : 0

  vpc_id     = aws_vpc.this.id
  cidr_block = var.public_subnets[count.index]

  # If create single public subnet, AWS will take care of availability zones
  availability_zone = local.nat_gateway_no > 1 ? var.azs[count.index] : null

  tags = merge(
    {
      "Name"        = "${var.environment}-${var.name}-public-${count.index}",
      "Environment" = var.environment
    },
    var.tags
  )
}

# ############################################################################
# Private Subnets
# ############################################################################
resource "aws_subnet" "private" {
  count = length(var.private_subnets) > 0 && length(var.private_subnets) <= 3 ? length(var.private_subnets) : 0

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = local.nat_gateway_no > 1 ? var.azs[count.index] : null

  tags = merge(
    {
      "Name"        = "${var.environment}-${var.name}-private-${count.index}",
      "Environment" = var.environment
    },
    var.tags
  )
}

# ############################################################################
# Database Subnets
# ############################################################################
resource "aws_subnet" "database" {
  count = length(var.database_subnets) > 0 && length(var.database_subnets) <= 3 ? length(var.database_subnets) : 0

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.database_subnets[count.index]
  availability_zone = local.nat_gateway_no > 1 ? var.azs[count.index] : null

  tags = merge(
    {
      "Name"        = "${var.environment}-${var.name}-database-${count.index}",
      "Environment" = var.environment
    },
    var.tags
  )
}
