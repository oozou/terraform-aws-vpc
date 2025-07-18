module "vpc" {
  source       = "../../"
  prefix       = var.prefix
  environment  = var.environment
  account_mode = "spoke"

  cidr              = "172.17.170.128/25"
  secondary_cidr    = "100.0.0.0/16"
  secondary_subnets = ["100.0.0.0/20", "100.0.16.0/20"]
  public_subnets    = ["172.17.170.192/28", "172.17.170.208/28"]
  private_subnets   = ["172.17.170.224/28", "172.17.170.240/28"]
  database_subnets  = ["172.17.170.128/27", "172.17.170.160/27"]
  availability_zone = ["ap-southeast-1b", "ap-southeast-1c"]

  is_create_nat_gateway             = true
  is_enable_single_nat_gateway      = false
  is_enable_dns_hostnames           = true
  is_enable_dns_support             = true
  is_create_flow_log                = true
  is_enable_flow_log_s3_integration = false
  is_create_secondary_nat_gateway   = true

  tags = var.custom_tags
}
