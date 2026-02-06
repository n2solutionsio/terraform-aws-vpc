################################################################################
# Simple VPC — Private subnets only
################################################################################

provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "../../"

  vpc_name = "simple-vpc"
  vpc_cidr = "10.0.0.0/16"

  enable_private_subnets = true
  private_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  default_tags = {
    Environment = "dev"
    Project     = "simple-example"
  }
}
