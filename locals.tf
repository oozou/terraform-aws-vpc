locals {
  # Ensure Nat gateway number is 1 and 3 only.
  nat_gateway_no = var.high_availability_mode ? 3 : 1

  default_tags = {
    "Environment" = var.environment,
    "Terraform"   = "true"
  }
}
