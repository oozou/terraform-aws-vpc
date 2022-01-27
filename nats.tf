# ############################################################################
# Nat Gateway
# ############################################################################
resource "aws_eip" "nat" {
  count = length(var.public_subnets) > 0 && length(var.public_subnets) <= 3 ? local.nat_gateway_no : 0

  vpc = true

  tags = merge(
    {
      "Name"        = format("${var.name}-${var.environment}-nat-%s", count.index),
      "Environment" = var.environment
    },
    var.tags
  )
}

resource "aws_nat_gateway" "nat" {
  count = length(var.public_subnets) > 0 && length(var.public_subnets) <= 3 ? local.nat_gateway_no : 0

  allocation_id = element(aws_eip.nat[*].id, count.index)
  subnet_id     = element(aws_subnet.public[*].id, count.index)

  tags = merge(
    {
      "Name"        = format("${var.name}-${var.environment}-nat-%s", count.index),
      "Environment" = var.environment
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.this[0]]
}
