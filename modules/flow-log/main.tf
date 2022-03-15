# Account Info Hub
data "aws_caller_identity" "current" {}

/* -------------------------------------------------------------------------- */
/*                         Flow Logs access CloudWatch                        */
/* -------------------------------------------------------------------------- */
resource "aws_cloudwatch_log_group" "flow_log" {
  count             = var.is_create_flow_log ? 1 : 0
  name              = "/aws/vpc/${local.name}-flow-log"
  retention_in_days = var.flow_log_retention_in_days

  tags = merge(local.tags, { Name = "/aws/vpc/${local.name}-flow-log" })
}

resource "aws_iam_role" "flow_log" {
  count               = var.is_create_flow_log ? 1 : 0
  name                = "${local.name}-role"
  managed_policy_arns = [aws_iam_policy.flow_log[count.index].arn]

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "vpc-flow-logs.amazonaws.com"
          ]
        },
        "Action" : [
          "sts:AssumeRole"
        ]
      }
    ]
  })
  tags = merge(local.tags, { Name = "${local.name}-flow-log-role" })
}

resource "aws_iam_policy" "flow_log" {
  count       = var.is_create_flow_log ? 1 : 0
  name        = "${local.name}-pushlog-policy"
  description = "${local.name}-pushlog-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" = "Allow"
        "Action" = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        "Resource" = "*"
      },
    ]
  })
  tags = merge(local.tags, { Name = "${local.name}-flow-log-pushlog-policy" })
}

/* -------------------------------------------------------------------------- */
/*                         Flow logs (CloudWatch dest)                        */
/* -------------------------------------------------------------------------- */
resource "aws_flow_log" "cloudwatch_dest" {
  count           = var.is_create_flow_log ? 1 : 0
  iam_role_arn    = aws_iam_role.flow_log[count.index].arn
  log_destination = aws_cloudwatch_log_group.flow_log[count.index].arn
  traffic_type    = "ALL"
  vpc_id          = var.vpc_id
  tags            = merge(local.tags, { Name = "${local.name}-flow-log-cloudwatch" })
}

/* -------------------------------------------------------------------------- */
/*                             Flow logs (S3 dest)                            */
/* -------------------------------------------------------------------------- */
resource "aws_flow_log" "s3_dest" {
  count                = var.is_create_flow_log && var.is_enable_flow_log_s3_integration ? 1 : 0
  log_destination      = local.centralize_flow_log_bucket_arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = var.vpc_id
  tags                 = merge(local.tags, { Name = "${local.name}-flow-log-s3" })
}
