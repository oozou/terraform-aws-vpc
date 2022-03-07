/* -------------------------------------------------------------------------- */
/*                                  Generics                                  */
/* -------------------------------------------------------------------------- */
locals {
  name        = format("%s-%s", var.prefix, var.environment)
  environment = var.environment

  max_subnet_length = max(
    length(var.public_subnets),
    length(var.private_subnets),
    length(var.database_subnets)
  )

  nat_gateway_count = var.is_enable_single_nat_gateway ? 1 : var.is_one_nat_gateway_per_az ? length(var.availability_zone) : local.max_subnet_length

  # Naming resouce with non-index
  vpc_name           = format("%s-vpc", local.name)
  vpc_dhcp_options   = format("%s-dhcp-options", local.name)
  vpc_default_sg     = format("%s-default-sg", local.name)
  public_route       = format("%s-public", local.name)
  vpc_flow_log_group = format("%s-log-group", local.name)
  vpc_flow_log       = format("%s-vpc-flowlog", local.name)
  vpc_flow_log_role  = format("%s-vpc-flowlog-role", local.name)

  tags = merge(
    {
      "Environment" = local.environment,
      "Terraform"   = "true"
    },
    var.tags
  )
}
