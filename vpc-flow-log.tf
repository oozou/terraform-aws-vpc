# IAM Role for VPC Flow Log
data "aws_iam_policy_document" "vpc_flow_log_role" {
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
  name               = "${var.environment}-${var.name}-vpc-flowlog"
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_log_role.json

  tags = merge(
    {
      "Name"        = "${var.environment}-${var.name}-vpc-flowlog",
      "Environment" = var.environment
    },
    var.tags
  )
}

# IAM Policy for Cloudwatch
data "aws_iam_policy_document" "vpc_flow_log" {
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
      aws_cloudwatch_log_group.vpc_flow_log.arn,
      "${aws_cloudwatch_log_group.vpc_flow_log.arn}:log-stream:*",
    ]
  }
}

resource "aws_iam_role_policy" "vpc_flow_log" {
  name   = "${var.environment}-${var.name}-vpc-flowlog"
  role   = aws_iam_role.vpc_flow_log.id
  policy = data.aws_iam_policy_document.vpc_flow_log.json
}

# VPC Flow Log
resource "aws_cloudwatch_log_group" "vpc_flow_log" {
  name              = "${var.environment}-${var.name}-vpc-flowlog"
  retention_in_days = var.flow_log_retention_in_days

  tags = merge(
    {
      "Name"        = "${var.environment}-${var.name}-vpc-flowlog"
      "Environment" = var.environment
    },
    var.tags
  )
}

resource "aws_flow_log" "vpc_flow_log" {
  log_destination = aws_cloudwatch_log_group.vpc_flow_log.arn
  iam_role_arn    = aws_iam_role.vpc_flow_log.arn
  vpc_id          = aws_vpc.this.id
  traffic_type    = "ALL"

  tags = merge(
    {
      "Name"        = "${var.environment}-${var.name}-vpc-flowlog",
      "Environment" = var.environment
    },
    var.tags
  )
}
