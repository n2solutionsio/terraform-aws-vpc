################################################################################
# Complete VPC — All features enabled
################################################################################

provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "../../"

  vpc_name = "complete-vpc"
  vpc_cidr = "10.0.0.0/16"

  # Availability zones
  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

  # Public subnets
  enable_public_subnets = true
  public_subnet_cidrs   = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # Private subnets
  enable_private_subnets = true
  private_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  # Database subnets
  enable_database_subnets = true
  database_subnet_cidrs   = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]

  # NAT Gateway — one per AZ for HA
  enable_nat_gateway = true
  single_nat_gateway = false

  # DNS
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Flow Logs
  enable_flow_logs        = true
  flow_log_retention_days = 90

  # VPC Endpoints
  enable_vpc_endpoints = true

  default_tags = {
    Environment = "production"
    Project     = "complete-example"
    Team        = "platform"
  }
}
