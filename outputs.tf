################################################################################
# VPC
################################################################################

output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "The ARN of the VPC."
  value       = aws_vpc.this.arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

################################################################################
# Subnets
################################################################################

output "public_subnet_ids" {
  description = "List of IDs of public subnets."
  value       = [for s in aws_subnet.public : s.id]
}

output "public_subnet_cidrs" {
  description = "List of CIDR blocks of public subnets."
  value       = [for s in aws_subnet.public : s.cidr_block]
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets."
  value       = [for s in aws_subnet.private : s.id]
}

output "private_subnet_cidrs" {
  description = "List of CIDR blocks of private subnets."
  value       = [for s in aws_subnet.private : s.cidr_block]
}

output "database_subnet_ids" {
  description = "List of IDs of database subnets."
  value       = [for s in aws_subnet.database : s.id]
}

output "database_subnet_cidrs" {
  description = "List of CIDR blocks of database subnets."
  value       = [for s in aws_subnet.database : s.cidr_block]
}

output "database_subnet_group_name" {
  description = "Name of the database subnet group."
  value       = try(aws_db_subnet_group.this[0].name, null)
}

################################################################################
# NAT Gateway
################################################################################

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs."
  value       = [for nat in aws_nat_gateway.this : nat.id]
}

output "nat_gateway_public_ips" {
  description = "List of public Elastic IPs associated with NAT Gateways."
  value       = [for eip in aws_eip.nat : eip.public_ip]
}

################################################################################
# Route Tables
################################################################################

output "public_route_table_ids" {
  description = "List of IDs of public route tables."
  value       = aws_route_table.public[*].id
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables."
  value       = [for rt in aws_route_table.private : rt.id]
}

output "database_route_table_ids" {
  description = "List of IDs of database route tables."
  value       = aws_route_table.database[*].id
}

################################################################################
# Internet Gateway
################################################################################

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = try(aws_internet_gateway.this[0].id, null)
}

################################################################################
# Flow Logs
################################################################################

output "flow_log_id" {
  description = "The ID of the VPC Flow Log."
  value       = try(aws_flow_log.this[0].id, null)
}

output "flow_log_cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for VPC Flow Logs."
  value       = try(aws_cloudwatch_log_group.flow_log[0].arn, null)
}

################################################################################
# VPC Endpoints
################################################################################

output "vpc_endpoint_s3_id" {
  description = "The ID of the S3 VPC Gateway Endpoint."
  value       = try(aws_vpc_endpoint.s3[0].id, null)
}

output "vpc_endpoint_dynamodb_id" {
  description = "The ID of the DynamoDB VPC Gateway Endpoint."
  value       = try(aws_vpc_endpoint.dynamodb[0].id, null)
}

################################################################################
# Availability Zones
################################################################################

output "azs" {
  description = "List of availability zones used."
  value       = local.azs
}
