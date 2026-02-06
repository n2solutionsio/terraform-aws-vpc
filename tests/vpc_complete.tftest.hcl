################################################################################
# VPC Complete — Test with ALL features enabled
################################################################################

mock_provider "aws" {}

variables {
  vpc_name = "test-complete-vpc"
  vpc_cidr = "10.2.0.0/16"
  azs      = ["us-east-1a", "us-east-1b", "us-east-1c"]

  enable_public_subnets = true
  public_subnet_cidrs   = ["10.2.101.0/24", "10.2.102.0/24", "10.2.103.0/24"]

  enable_private_subnets = true
  private_subnet_cidrs   = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]

  enable_database_subnets = true
  database_subnet_cidrs   = ["10.2.201.0/24", "10.2.202.0/24", "10.2.203.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false

  enable_flow_logs        = true
  flow_log_retention_days = 90

  enable_vpc_endpoints = true

  default_tags = {
    Environment = "test"
  }
}

run "all_subnets_created" {
  command = plan

  assert {
    condition     = length(aws_subnet.public) == 3
    error_message = "Expected 3 public subnets."
  }

  assert {
    condition     = length(aws_subnet.private) == 3
    error_message = "Expected 3 private subnets."
  }

  assert {
    condition     = length(aws_subnet.database) == 3
    error_message = "Expected 3 database subnets."
  }
}

run "ha_nat_gateways" {
  command = plan

  assert {
    condition     = length(aws_nat_gateway.this) == 3
    error_message = "Expected 3 NAT gateways (one per AZ) when single_nat_gateway is false."
  }

  assert {
    condition     = length(aws_eip.nat) == 3
    error_message = "Expected 3 EIPs for HA NAT gateways."
  }
}

run "database_subnet_group_created" {
  command = plan

  assert {
    condition     = length(aws_db_subnet_group.this) == 1
    error_message = "Expected database subnet group to be created."
  }
}

run "database_route_table_created" {
  command = plan

  assert {
    condition     = length(aws_route_table.database) == 1
    error_message = "Expected 1 database route table."
  }
}

run "flow_logs_enabled" {
  command = plan

  assert {
    condition     = length(aws_flow_log.this) == 1
    error_message = "Expected VPC flow log to be created."
  }

  assert {
    condition     = length(aws_cloudwatch_log_group.flow_log) == 1
    error_message = "Expected CloudWatch log group for flow logs."
  }

  assert {
    condition     = length(aws_iam_role.flow_log) == 1
    error_message = "Expected IAM role for flow logs."
  }

  assert {
    condition     = aws_cloudwatch_log_group.flow_log[0].retention_in_days == 90
    error_message = "Flow log retention should be 90 days."
  }
}

run "vpc_endpoints_created" {
  command = plan

  assert {
    condition     = length(aws_vpc_endpoint.s3) == 1
    error_message = "Expected S3 VPC endpoint."
  }

  assert {
    condition     = length(aws_vpc_endpoint.dynamodb) == 1
    error_message = "Expected DynamoDB VPC endpoint."
  }
}

run "tags_propagated" {
  command = plan

  assert {
    condition     = aws_vpc.this.tags["Environment"] == "test"
    error_message = "Custom default_tags should propagate to VPC."
  }

  assert {
    condition     = aws_vpc.this.tags["module"] == "terraform-aws-vpc"
    error_message = "Module tag should be set."
  }
}
