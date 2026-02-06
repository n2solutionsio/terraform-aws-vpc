################################################################################
# VPC
################################################################################

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = local.vpc_tags
}

################################################################################
# Public Subnets
################################################################################

resource "aws_subnet" "public" {
  for_each = var.enable_public_subnets ? { for idx, az in local.azs : az => idx } : {}

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[each.value]
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix}-public-${each.key}"
      "Tier" = "public"
    },
  )
}

################################################################################
# Private Subnets
################################################################################

resource "aws_subnet" "private" {
  for_each = var.enable_private_subnets ? { for idx, az in local.azs : az => idx } : {}

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[each.value]
  availability_zone = each.key

  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix}-private-${each.key}"
      "Tier" = "private"
    },
  )
}

################################################################################
# Database Subnets
################################################################################

resource "aws_subnet" "database" {
  for_each = var.enable_database_subnets ? { for idx, az in local.azs : az => idx } : {}

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.database_subnet_cidrs[each.value]
  availability_zone = each.key

  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix}-database-${each.key}"
      "Tier" = "database"
    },
  )
}

################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "this" {
  count = var.enable_public_subnets ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix}-igw"
    },
  )
}

################################################################################
# Elastic IPs for NAT Gateways
################################################################################

resource "aws_eip" "nat" {
  for_each = var.enable_nat_gateway ? { for az in slice(local.azs, 0, local.nat_gateway_count) : az => az } : {}

  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix}-nat-eip-${each.key}"
    },
  )

  depends_on = [aws_internet_gateway.this]
}

################################################################################
# NAT Gateways
################################################################################

resource "aws_nat_gateway" "this" {
  for_each = var.enable_nat_gateway ? { for az in slice(local.azs, 0, local.nat_gateway_count) : az => az } : {}

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix}-nat-${each.key}"
    },
  )

  depends_on = [aws_internet_gateway.this]
}

################################################################################
# Public Route Table
################################################################################

resource "aws_route_table" "public" {
  count = var.enable_public_subnets ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix}-public"
    },
  )
}

resource "aws_route" "public_internet" {
  count = var.enable_public_subnets ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_route_table_association" "public" {
  for_each = var.enable_public_subnets ? { for idx, az in local.azs : az => idx } : {}

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public[0].id
}

################################################################################
# Private Route Tables
################################################################################

resource "aws_route_table" "private" {
  for_each = var.enable_private_subnets ? { for idx, az in local.azs : az => idx } : {}

  vpc_id = aws_vpc.this.id

  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix}-private-${each.key}"
    },
  )
}

resource "aws_route" "private_nat" {
  for_each = var.enable_nat_gateway && var.enable_private_subnets ? { for idx, az in local.azs : az => idx } : {}

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[local.az_to_nat_key[each.value]].id
}

resource "aws_route_table_association" "private" {
  for_each = var.enable_private_subnets ? { for idx, az in local.azs : az => idx } : {}

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

################################################################################
# Database Route Table
################################################################################

resource "aws_route_table" "database" {
  count = var.enable_database_subnets ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix}-database"
    },
  )
}

resource "aws_route_table_association" "database" {
  for_each = var.enable_database_subnets ? { for idx, az in local.azs : az => idx } : {}

  subnet_id      = aws_subnet.database[each.key].id
  route_table_id = aws_route_table.database[0].id
}

################################################################################
# Database Subnet Group
################################################################################

resource "aws_db_subnet_group" "this" {
  count = var.enable_database_subnets ? 1 : 0

  name        = "${local.name_prefix}-db"
  description = "Database subnet group for ${local.name_prefix}"
  subnet_ids  = [for s in aws_subnet.database : s.id]

  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix}-db"
    },
  )
}

################################################################################
# Default Security Group — deny all traffic
################################################################################

resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix}-default-sg-restricted"
    },
  )
}

################################################################################
# Default Network ACL — deny all traffic
################################################################################

resource "aws_default_network_acl" "this" {
  default_network_acl_id = aws_vpc.this.default_network_acl_id

  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix}-default-nacl-deny-all"
    },
  )

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

################################################################################
# VPC Flow Logs
################################################################################

resource "aws_cloudwatch_log_group" "flow_log" {
  count = var.enable_flow_logs ? 1 : 0

  name              = "/aws/vpc-flow-log/${local.name_prefix}"
  retention_in_days = var.flow_log_retention_days

  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix}-flow-log"
    },
  )
}

resource "aws_iam_role" "flow_log" {
  count = var.enable_flow_logs ? 1 : 0

  name = "${local.name_prefix}-vpc-flow-log"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "flow_log" {
  count = var.enable_flow_logs ? 1 : 0

  name = "${local.name_prefix}-vpc-flow-log"
  role = aws_iam_role.flow_log[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
        ]
        Resource = "${aws_cloudwatch_log_group.flow_log[0].arn}:*"
      },
    ]
  })
}

resource "aws_flow_log" "this" {
  count = var.enable_flow_logs ? 1 : 0

  vpc_id          = aws_vpc.this.id
  iam_role_arn    = aws_iam_role.flow_log[0].arn
  log_destination = aws_cloudwatch_log_group.flow_log[0].arn
  traffic_type    = "ALL"

  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix}-flow-log"
    },
  )
}

################################################################################
# VPC Endpoints — Gateway type (S3 and DynamoDB)
################################################################################

resource "aws_vpc_endpoint" "s3" {
  count = var.enable_vpc_endpoints ? 1 : 0

  vpc_id       = aws_vpc.this.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"

  route_table_ids = concat(
    var.enable_public_subnets ? [aws_route_table.public[0].id] : [],
    var.enable_private_subnets ? [for rt in aws_route_table.private : rt.id] : [],
    var.enable_database_subnets ? [aws_route_table.database[0].id] : [],
  )

  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix}-s3-endpoint"
    },
  )
}

resource "aws_vpc_endpoint" "dynamodb" {
  count = var.enable_vpc_endpoints ? 1 : 0

  vpc_id       = aws_vpc.this.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.dynamodb"

  route_table_ids = concat(
    var.enable_public_subnets ? [aws_route_table.public[0].id] : [],
    var.enable_private_subnets ? [for rt in aws_route_table.private : rt.id] : [],
    var.enable_database_subnets ? [aws_route_table.database[0].id] : [],
  )

  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix}-dynamodb-endpoint"
    },
  )
}
