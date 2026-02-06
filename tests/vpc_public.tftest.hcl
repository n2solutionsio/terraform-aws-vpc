################################################################################
# VPC Public — Test with public subnets and NAT gateway enabled
################################################################################

mock_provider "aws" {}

variables {
  vpc_name = "test-public-vpc"
  vpc_cidr = "10.1.0.0/16"
  azs      = ["us-east-1a", "us-east-1b", "us-east-1c"]

  enable_public_subnets = true
  public_subnet_cidrs   = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]

  enable_private_subnets = true
  private_subnet_cidrs   = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_flow_logs = false
}

run "public_subnets_created" {
  command = plan

  assert {
    condition     = length(aws_subnet.public) == 3
    error_message = "Expected 3 public subnets."
  }
}

run "private_subnets_created" {
  command = plan

  assert {
    condition     = length(aws_subnet.private) == 3
    error_message = "Expected 3 private subnets."
  }
}

run "internet_gateway_created" {
  command = plan

  assert {
    condition     = length(aws_internet_gateway.this) == 1
    error_message = "Expected 1 internet gateway."
  }
}

run "single_nat_gateway_created" {
  command = plan

  assert {
    condition     = length(aws_nat_gateway.this) == 1
    error_message = "Expected 1 NAT gateway when single_nat_gateway is true."
  }

  assert {
    condition     = length(aws_eip.nat) == 1
    error_message = "Expected 1 EIP when single_nat_gateway is true."
  }
}

run "public_route_table_created" {
  command = plan

  assert {
    condition     = length(aws_route_table.public) == 1
    error_message = "Expected 1 public route table."
  }

  assert {
    condition     = length(aws_route.public_internet) == 1
    error_message = "Expected 1 public internet route."
  }
}

run "private_route_tables_created" {
  command = plan

  assert {
    condition     = length(aws_route_table.private) == 3
    error_message = "Expected 3 private route tables (one per AZ)."
  }

  assert {
    condition     = length(aws_route.private_nat) == 3
    error_message = "Expected 3 private NAT routes (one per AZ)."
  }
}

run "public_subnet_has_public_ip" {
  command = plan

  assert {
    condition     = aws_subnet.public["us-east-1a"].map_public_ip_on_launch == true
    error_message = "Public subnets should map public IP on launch."
  }
}
