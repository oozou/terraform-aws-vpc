# ############################################################################
# Internet Gateway
# ############################################################################
resource "aws_internet_gateway" "this" {
  count = length(var.public_subnets) > 0 && length(var.public_subnets) <= 3 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name"        = "${var.name}-${var.environment}-internet-gateway",
      "Environment" = var.environment,
      "Terraform"   = "true"
    },
    var.tags
  )
}
