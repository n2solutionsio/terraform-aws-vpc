################################################################################
# VPC Basic — Test VPC creation with defaults only
################################################################################

mock_provider "aws" {}

variables {
  vpc_name               = "test-basic-vpc"
  vpc_cidr               = "10.0.0.0/16"
  enable_private_subnets = false
  enable_flow_logs       = false
}

run "vpc_defaults" {
  command = plan

  assert {
    condition     = aws_vpc.this.cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR block does not match expected value."
  }

  assert {
    condition     = aws_vpc.this.enable_dns_support == true
    error_message = "DNS support should be enabled by default."
  }

  assert {
    condition     = aws_vpc.this.enable_dns_hostnames == true
    error_message = "DNS hostnames should be enabled by default."
  }

  assert {
    condition     = aws_vpc.this.tags["Name"] == "test-basic-vpc"
    error_message = "VPC Name tag does not match."
  }

  assert {
    condition     = aws_vpc.this.tags["terraform-managed"] == "true"
    error_message = "terraform-managed tag should be set."
  }
}

run "no_public_subnets_by_default" {
  command = plan

  assert {
    condition     = length(aws_subnet.public) == 0
    error_message = "No public subnets should be created by default."
  }
}

run "no_nat_gateway_by_default" {
  command = plan

  assert {
    condition     = length(aws_nat_gateway.this) == 0
    error_message = "No NAT gateways should be created by default."
  }

  assert {
    condition     = length(aws_eip.nat) == 0
    error_message = "No EIPs should be created by default."
  }
}

run "no_database_subnets_by_default" {
  command = plan

  assert {
    condition     = length(aws_subnet.database) == 0
    error_message = "No database subnets should be created by default."
  }
}

run "security_resources_created" {
  command = plan

  assert {
    condition     = aws_default_security_group.this.tags["Name"] == "test-basic-vpc-default-sg-restricted"
    error_message = "Default security group should have restrictive Name tag."
  }

  assert {
    condition     = aws_default_network_acl.this.tags["Name"] == "test-basic-vpc-default-nacl-deny-all"
    error_message = "Default NACL should have deny-all Name tag."
  }
}
