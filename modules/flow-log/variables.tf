/* -------------------------------------------------------------------------- */
/*                                  GENERICS                                  */
/* -------------------------------------------------------------------------- */
variable "prefix" {
  description = "The prefix name of customer to be displayed in AWS console and resource"
  type        = string
}

variable "environment" {
  description = "Environment name used as environment resources name."
  type        = string
}

variable "tags" {
  description = "Tags to add more; default tags contian {terraform=true, environment=var.environment}"
  type        = map(string)
  default     = {}
}

/* -------------------------------------------------------------------------- */
/*                                 Flow Log                                   */
/* -------------------------------------------------------------------------- */
variable "is_enable_flow_log" {
  description = "Whether to enable flow log."
  type        = bool
  default     = true
}

variable "is_enable_flow_log_s3_integration" {
  description = "Whether to enable flow log S3 integration."
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "Flow log will configure in this VPC."
  type        = string
}

variable "flow_log_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group for VPC flow logs."
  type        = number
  default     = 90
}

variable "centralize_flow_log_bucket_name" {
  description = "S3 bucket for store Cloudtrail log (long terms), leave this default if account_mode is hub. If account_mode is spoke, please provide centrailize flow log S3 bucket name (hub)."
  type        = string
  default     = ""
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key. Leave this default if account_mode is hub. If account_mode is spoke, please provide centrailize kms key arn (hub)."
  type        = string
  default     = ""
}

/* -------------------------------------------------------------------------- */
/*                            Account Configuration                           */
/* -------------------------------------------------------------------------- */
variable "account_mode" {
  description = "Account mode for provision cloudtrail, if account_mode is hub, will provision S3, KMS, CloudTrail. if account_mode is spoke, will provision only CloudTrail"
  type        = string
  validation {
    condition     = contains(["hub", "spoke"], var.account_mode)
    error_message = "Valid values for account_mode are hub and spoke."
  }
}

variable "spoke_account_ids" {
  description = "Spoke account Ids, if mode is hub."
  type        = list(string)
  default     = []
}

/* -------------------------------------------------------------------------- */
/*                                  S3 Bucket                                 */
/* -------------------------------------------------------------------------- */

variable "centralize_flow_log_bucket_lifecycle_rule" {
  description = "List of lifecycle rules to transition the data. Leave empty to disable this feature. storage_class can be STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, GLACIER, or DEEP_ARCHIVE"
  type = list(object({
    id = string

    transition = list(object({
      days          = number
      storage_class = string
    }))

    expiration_days = number
  }))
  default = []
}
