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

  tags = merge(
    {
      "Environment" = local.environment,
      "Terraform"   = "true"
    },
    var.tags
  )
}

/* -------------------------------------------------------------------------- */
/*                                     VPC                                    */
/* -------------------------------------------------------------------------- */
resource "aws_vpc" "this" {
  count = var.is_create_vpc ? 1 : 0

  cidr_block                       = var.cidr
  instance_tenancy                 = var.instance_tenancy
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  enable_classiclink               = var.enable_classiclink
  enable_classiclink_dns_support   = var.enable_classiclink_dns_support
  assign_generated_ipv6_cidr_block = var.enable_ipv6

  tags = merge(
    local.tags,
    { "Name" = format("%s-%s", local.name, "vpc") }
  )
}

resource "aws_vpc_dhcp_options" "this" {
  count = var.enable_dhcp_options && var.is_create_vpc ? 1 : 0

  domain_name          = var.dhcp_options_domain_name
  domain_name_servers  = var.dhcp_options_domain_name_servers
  ntp_servers          = var.dhcp_options_ntp_servers
  netbios_name_servers = var.dhcp_options_netbios_name_servers
  netbios_node_type    = var.dhcp_options_netbios_node_type

  tags = merge(
    local.tags,
    { "Name" = format("%s-%s", local.name, "dhcp-options") }
  )
}

resource "aws_vpc_dhcp_options_association" "this" {
  count = var.enable_dhcp_options && var.is_create_vpc ? 1 : 0

  vpc_id          = aws_vpc.this[0].id
  dhcp_options_id = aws_vpc_dhcp_options.this[0].id
}

resource "aws_default_security_group" "this" {
  count = var.is_create_vpc ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    local.tags,
    { "Name" = format("%s-%s", local.name, "default-sg") }
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
    { "Name" = format("%s-%s", local.name, "internet-gateway") }
  )
}

/* -------------------------------------------------------------------------- */
/*                                   Subnets                                  */
/* -------------------------------------------------------------------------- */
/* ----------------------------- public subnets ----------------------------- */
resource "aws_subnet" "public" {
  count = var.is_create_vpc && length(var.public_subnets) > 0 && (false == var.is_one_nat_gateway_per_az || length(var.public_subnets) >= length(var.availability_zone)) ? length(var.public_subnets) : 0

  vpc_id     = aws_vpc.this[0].id
  cidr_block = var.public_subnets[count.index]

  # If create single public subnet, AWS will take care of availability zones
  availability_zone = local.nat_gateway_count > 1 ? var.availability_zone[count.index] : null

  tags = merge(
    local.tags,
    { "Name" = format("%s-%s-%s", local.name, "public", count.index) }
  )
}
/* ----------------------------- private subnets ---------------------------- */
resource "aws_subnet" "private" {
  count = var.is_create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  vpc_id            = aws_vpc.this[0].id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = local.nat_gateway_count > 1 ? var.availability_zone[count.index] : null

  tags = merge(
    local.tags,
    { "Name" = format("%s-%s-%s", local.name, "private", count.index) }
  )
}
/* ---------------------------- database subnets ---------------------------- */
resource "aws_subnet" "database" {
  count = var.is_create_vpc && length(var.database_subnets) > 0 ? length(var.database_subnets) : 0

  vpc_id            = aws_vpc.this[0].id
  cidr_block        = var.database_subnets[count.index]
  availability_zone = local.nat_gateway_count > 1 ? var.availability_zone[count.index] : null

  tags = merge(
    local.tags,
    { "Name" = format("%s-%s-%s", local.name, "database", count.index) }
  )
}

/* -------------------------------------------------------------------------- */
/*                                     NAT                                    */
/* -------------------------------------------------------------------------- */
resource "aws_eip" "nat" {
  count = var.is_create_vpc && var.is_create_nat_gateway ? local.nat_gateway_count : 0

  vpc = true

  tags = merge(
    local.tags,
    { "Name" = format("%s-%s-%s", local.name, "eip-nat", count.index) }
  )
}

resource "aws_nat_gateway" "nat" {
  count = var.is_create_vpc && var.is_create_nat_gateway ? local.nat_gateway_count : 0

  depends_on = [aws_internet_gateway.this[0]]

  allocation_id = element(aws_eip.nat[*].id, var.is_enable_single_nat_gateway ? 0 : count.index)
  subnet_id     = element(aws_subnet.public[*].id, var.is_enable_single_nat_gateway ? 0 : count.index)

  tags = merge(
    local.tags,
    { "Name" = format("%s-%s-%s", local.name, "nat", count.index) }
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
    { "Name" = format("%s-%s", local.name, "public") }
  )
}

resource "aws_route" "public_internet_gateway" {
  count = var.is_create_vpc && var.is_create_internet_gateway && length(var.public_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_route" "public_internet_gateway_ipv6" {
  count = var.is_create_vpc && var.is_create_internet_gateway && var.enable_ipv6 && length(var.public_subnets) > 0 ? 1 : 0

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
    { "Name" = local.nat_gateway_count > 1 ? format("%s-%s-%s", local.name, "private", count.index) : format("%s-%s", local.name, "private") }
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
  count = var.is_create_vpc && var.is_create_nat_gateway && var.enable_ipv6 && length(var.private_subnets) > 0 ? local.nat_gateway_count : 0

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
  # previous configuration
  # count = length(var.database_subnets) > 0 && length(var.database_subnets) <= 3 ? local.nat_gateway_no : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    local.tags,
    { "Name" = local.nat_gateway_count > 1 ? format("%s-%s-%s", local.name, "database", count.index) : format("%s-%s", local.name, "database") }
  )
}

resource "aws_route" "database_nat_gateway" {
  count = var.is_create_vpc && var.is_create_database_subnet_route_table && length(var.database_subnets) > 0 && var.is_create_nat_gateway ? var.is_enable_single_nat_gateway ? 1 : length(var.database_subnets) : 0
  # previous configuration
  # count = length(var.database_subnets) > 0 && length(var.database_subnets) <= 3 ? local.nat_gateway_no : 0

  route_table_id         = element(aws_route_table.database[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat[*].id, count.index)

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "database_nat_gateway_ipv6" {
  count = var.is_create_vpc && var.is_create_database_subnet_route_table && var.enable_ipv6 && length(var.database_subnets) > 0 && var.is_create_nat_gateway ? var.is_enable_single_nat_gateway ? 1 : length(var.database_subnets) : 0
  # previous configuration
  # count = var.enable_ipv6 && length(var.database_subnets) > 0 && length(var.database_subnets) <= 3 ? local.nat_gateway_no : 0

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
/*                                VPC Flow Logs                               */
/* -------------------------------------------------------------------------- */
/* ----------------------------- cloudwatch logs ---------------------------- */
resource "aws_cloudwatch_log_group" "vpc_flow_log" {
  count = var.is_create_vpc && var.is_create_vpc_flow_logs ? 1 : 0

  name              = format("%s-%s", local.name, "vpc-flowlog")
  retention_in_days = var.flow_log_retention_in_days

  tags = merge(
    local.tags,
    { "Name" = format("%s-%s", local.name, "vpc-flowlog") }
  )
}

resource "aws_flow_log" "vpc_flow_log" {
  count = var.is_create_vpc && var.is_create_vpc_flow_logs ? 1 : 0

  log_destination = aws_cloudwatch_log_group.vpc_flow_log[0].arn
  iam_role_arn    = aws_iam_role.vpc_flow_log[0].arn
  vpc_id          = aws_vpc.this[0].id
  traffic_type    = "ALL"

  tags = merge(
    local.tags,
    { "Name" = format("%s-%s", local.name, "vpc-flowlog") }
  )
}

/* ---------------------------- flow log policies --------------------------- */
data "aws_iam_policy_document" "vpc_flow_log_role" {
  count = var.is_create_vpc && var.is_create_vpc_flow_logs ? 1 : 0

  statement {
    sid     = "AssumeRolePolicy"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "vpc_flow_log" {
  count = var.is_create_vpc && var.is_create_vpc_flow_logs ? 1 : 0

  name               = format("%s-%s", local.name, "vpc-flowlog")
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_log_role[0].json

  tags = merge(
    local.tags,
    { "Name" = format("%s-%s", local.name, "vpc-flowlog") }
  )
}

data "aws_iam_policy_document" "vpc_flow_log" {
  count = var.is_create_vpc && var.is_create_vpc_flow_logs ? 1 : 0

  statement {
    sid       = "AllowReadAllLogGroups"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
  }

  statement {
    sid    = "AllowWriteToLogGroupVpcFlow"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      aws_cloudwatch_log_group.vpc_flow_log[0].arn,
      "${aws_cloudwatch_log_group.vpc_flow_log[0].arn}:log-stream:*",
    ]
  }
}

resource "aws_iam_role_policy" "vpc_flow_log" {
  count = var.is_create_vpc && var.is_create_vpc_flow_logs ? 1 : 0

  name   = format("%s-%s", local.name, "vpc-flowlog")
  role   = aws_iam_role.vpc_flow_log[0].id
  policy = data.aws_iam_policy_document.vpc_flow_log[0].json
}
