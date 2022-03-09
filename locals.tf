/* -------------------------------------------------------------------------- */
/*                                  Generics                                  */
/* -------------------------------------------------------------------------- */
locals {
  name = format("%s-%s", var.prefix, var.environment)

  max_subnet_length = max(
    length(var.public_subnets),
    length(var.private_subnets),
    length(var.database_subnets)
  )

  nat_gateway_count = var.is_enable_single_nat_gateway ? 1 : var.is_one_nat_gateway_per_az ? length(var.availability_zone) : local.max_subnet_length

  availability_zone_shoten = [for az in var.availability_zone : element(split("-", az), 2)]

  tags = merge(
    {
      "Environment" = var.environment,
      "Terraform"   = "true"
    },
    var.tags
  )
}
