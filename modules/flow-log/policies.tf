data "aws_iam_policy_document" "kms_flow_log" {
  count = 1 - local.account_mode
  statement {
    sid    = "Allow VPC Flow Logs to use the key"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }

  statement {
    sid    = "Allow attachment of persistant resources"
    effect = "Allow"
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = ["*"]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }

  statement {
    sid    = "Allow CloudWatch log Key Permission"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:ap-southeast-1:*:log-group:/aws/vpc/${var.prefix}*"]
    }
  }
}

data "aws_iam_policy_document" "s3_flow_log" {
  count = 1 - local.account_mode
  statement {
    sid    = "VpcFlowLogsAclCheck"
    effect = "Allow"
    actions = [
      "s3:GetBucketAcl",
      "s3:ListBucket"
    ]
    resources = [local.centralize_flow_log_bucket_arn]
    principals {
      identifiers = [
        "delivery.logs.amazonaws.com"
      ]
      type = "Service"
    }
  }

  statement {
    sid    = "VpcFlowLogsWrite"
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = [for account in local.account_ids : join("", [local.centralize_flow_log_bucket_arn, "/AWSLogs/", account, "/*"])]
    principals {
      identifiers = [
        "delivery.logs.amazonaws.com"
      ]
      type = "Service"
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid    = "DenyDeleteObject"
    effect = "Deny"
    actions = [
      "s3:Delete*"
    ]
    resources = [
      local.centralize_flow_log_bucket_arn,
      "${local.centralize_flow_log_bucket_arn}/*"
    ]
    principals {
      identifiers = ["*"]
      type        = "*"
    }
  }
}
