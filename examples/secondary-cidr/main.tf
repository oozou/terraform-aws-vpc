module "vpc" {
  source       = "../../"
  prefix       = var.prefix
  environment  = var.environment
  account_mode = "hub"

  cidr              = "172.17.170.128/25"
  secondary_cidr    = "100.64.0.0/22"
  secondary_subnets = ["100.64.0.0/23", "100.64.2.0/23"]
  public_subnets    = ["172.17.170.192/28", "172.17.170.208/28"]
  private_subnets   = ["172.17.170.224/28", "172.17.170.240/28"]
  database_subnets  = ["172.17.170.128/27", "172.17.170.160/27"]
  availability_zone = ["ap-southeast-1b", "ap-southeast-1c"]

  is_create_nat_gateway             = true
  is_create_secondary_nat_gateway   = false # Optional to create nat gateway for secondary subnet or not
  is_enable_single_nat_gateway      = false
  is_enable_dns_hostnames           = true
  is_enable_dns_support             = true
  is_create_flow_log                = false
  is_enable_flow_log_s3_integration = false

  tags = var.custom_tags
}
