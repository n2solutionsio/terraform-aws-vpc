locals {
  # Use provided AZs or fall back to first 3 available in the region
  azs = length(var.azs) > 0 ? var.azs : slice(data.aws_availability_zones.available.names, 0, min(3, length(data.aws_availability_zones.available.names)))

  # Number of AZs to deploy across
  az_count = length(local.azs)

  # Common name prefix
  name_prefix = var.vpc_name

  # Merged tags applied to all resources
  common_tags = merge(
    var.default_tags,
    {
      "terraform-managed" = "true"
      "module"            = "terraform-aws-vpc"
    },
  )

  # VPC-specific tags
  vpc_tags = merge(
    local.common_tags,
    {
      "Name" = local.name_prefix
    },
  )

  # NAT Gateway: determine how many to create
  # single_nat_gateway = true  → 1 NAT in first AZ
  # single_nat_gateway = false → 1 NAT per AZ
  nat_gateway_count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : local.az_count) : 0

  # Map of AZ index → NAT gateway key for route table lookups
  # When single NAT, all AZs point to the same NAT (index 0)
  az_to_nat_key = {
    for idx in range(local.az_count) :
    idx => var.single_nat_gateway ? local.azs[0] : local.azs[idx]
  }
}
