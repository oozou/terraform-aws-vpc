/* -------------------------------------------------------------------------- */
/*                                  Generics                                  */
/* -------------------------------------------------------------------------- */
variable "prefix" {
  description = "The prefix name of customer to be displayed in AWS console and resource"
  type        = string
}

variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
}

variable "tags" {
  description = "Tags to add more; default tags contian {terraform=true, environment=var.environment}"
  type        = map(string)
  default     = {}
}

variable "is_enable_eks_auto_discovery" {
  description = "Tags public, private subnet to auto discovery"
  type        = bool
  default     = true
}

/* -------------------------------------------------------------------------- */
/*                                     VPC                                    */
/* -------------------------------------------------------------------------- */
variable "is_create_vpc" {
  description = "Whether to create vpc or not"
  type        = bool
  default     = true
}

variable "cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  type        = string
  default     = "default"
}

variable "is_enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = false
}

variable "is_enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "is_enable_classiclink" {
  description = "Should be true to enable ClassicLink for the VPC. Only valid in regions and accounts that support EC2 Classic."
  type        = bool
  default     = null
}

variable "is_enable_classiclink_dns_support" {
  description = "Should be true to enable ClassicLink DNS Support for the VPC. Only valid in regions and accounts that support EC2 Classic."
  type        = bool
  default     = null
}

variable "is_enable_ipv6" {
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block."
  type        = bool
  default     = false
}
/* ------------------------------ DHCP options ------------------------------ */
variable "is_enable_dhcp_options" {
  description = "Should be true if you want to specify a DHCP options set with a custom domain name, DNS servers, NTP servers, netbios servers, and/or netbios server type"
  type        = bool
  default     = false
}

variable "dhcp_options_domain_name" {
  description = "Specifies DNS name for DHCP options set (requires enable_dhcp_options set to true)"
  type        = string
  default     = ""
}

variable "dhcp_options_domain_name_servers" {
  description = "Specify a list of DNS server addresses for DHCP options set, default to AWS provided (requires enable_dhcp_options set to true)"
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
}

variable "dhcp_options_ntp_servers" {
  description = "Specify a list of NTP servers for DHCP options set (requires enable_dhcp_options set to true)"
  type        = list(string)
  default     = []
}

variable "dhcp_options_netbios_name_servers" {
  description = "Specify a list of netbios servers for DHCP options set (requires enable_dhcp_options set to true)"
  type        = list(string)
  default     = []
}

variable "dhcp_options_netbios_node_type" {
  description = "Specify netbios node_type for DHCP options set (requires enable_dhcp_options set to true)"
  type        = string
  default     = ""
}

/* -------------------------------------------------------------------------- */
/*                              Internet Gateway                              */
/* -------------------------------------------------------------------------- */
variable "is_create_internet_gateway" {
  description = "Whether to create igw or not"
  type        = bool
  default     = true
}

/* -------------------------------------------------------------------------- */
/*                                 NAT Gateway                                */
/* -------------------------------------------------------------------------- */
variable "is_create_nat_gateway" {
  description = "Whether to create nat gatewat or not"
  type        = bool
  default     = false
}

variable "is_enable_single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = false
}

variable "is_one_nat_gateway_per_az" {
  description = "Enable multiple Nat gateway and public subnets with Multi-AZ"
  type        = bool
  default     = false
}

/* -------------------------------------------------------------------------- */
/*                                   Subnet                                   */
/* -------------------------------------------------------------------------- */
variable "availability_zone" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
}
/* ----------------------------- public subnets ----------------------------- */
variable "public_subnets" {
  description = "The CIDR block for the public subnets. Required 3 subnets for availability zones"
  type        = list(string)
}
/* ----------------------------- private subnets ---------------------------- */
variable "private_subnets" {
  description = "The CIDR block for the private subnets. Required 3 subnets for availability zones"
  type        = list(string)
}
/* ---------------------------- database subnets ---------------------------- */
variable "database_subnets" {
  description = "The CIDR block for the database subnets. Required 3 subnets for availability zones"
  type        = list(string)
  default     = []
}

/* -------------------------------------------------------------------------- */
/*                            Database Route Table                            */
/* -------------------------------------------------------------------------- */
variable "is_create_database_subnet_route_table" {
  description = "Whether to create database subnet or not"
  type        = bool
  default     = true
}

/* -------------------------------------------------------------------------- */
/*                                VPC Flow Log                                */
/* -------------------------------------------------------------------------- */
variable "is_create_flow_log" {
  description = "Whether to create flow log."
  type        = bool
  default     = true
}

variable "is_enable_flow_log_s3_integration" {
  description = "Whether to enable flow log S3 integration."
  type        = bool
  default     = true
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

variable "centrailize_flow_log_kms_key_id" {
  description = "The ARN for the KMS encryption key. Leave this default if account_mode is hub. If account_mode is spoke, please provide centrailize kms key arn (hub)."
  type        = string
  default     = ""
}

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

variable "is_map_public_ip_on_launch_public_subnet" {
  description = "Specify true to indicate that instances launched into public subnets will be assigned a public IP address"
  type        = bool
  default     = false
}
