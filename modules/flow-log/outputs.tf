output "flow_log_cloudwatch_dest_id" {
  description = "Flow log CloudWatch Id"
  value       = join("", aws_flow_log.cloudwatch_dest[*].id)
}

output "flow_log_cloudwatch_dest_arn" {
  description = "Flow log CloudWatch ARN"
  value       = join("", aws_flow_log.cloudwatch_dest[*].arn)
}

output "flow_log_s3_dest_id" {
  description = "Flow log S3 Id"
  value       = join("", aws_flow_log.s3_dest[*].id)
}

output "flow_log_s3_dest_arn" {
  description = "Flow log S3 ARN"
  value       = join("", aws_flow_log.s3_dest[*].arn)
}

output "centralize_flow_log_bucket_name" {
  description = "S3 Centralize Flow log Bucket Name"
  value       = join("", module.centralize_flow_log_bucket[*].bucket_name)
}

output "centralize_flow_log_bucket_arn" {
  description = "S3 Centralize Flow log Bucket ARN"
  value       = join("", module.centralize_flow_log_bucket[*].bucket_arn)
}

output "centralize_flow_log_key_arn" {
  description = "KMS Centralize Flow log key arn"
  value       = join("", module.flow_log_kms[*].key_arn)
}

output "centralize_flow_log_key_id" {
  description = "KMS Centralize Flow log key id"
  value       = join("", module.flow_log_kms[*].key_id)
}


output "flow_log_cloudwatch_log_group_name" {
  description = "Flow log CloudWatch Log Group Name"
  value       = try(aws_cloudwatch_log_group.flow_log[0].name, "")
}

output "flow_log_cloudwatch_log_group_arn" {
  description = "Flow log CloudWatch Log Group ARN"
  value       = try(aws_cloudwatch_log_group.flow_log[0].arn, "")
}