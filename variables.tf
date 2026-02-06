################################################################################
# VPC
################################################################################

variable "vpc_name" {
  description = "Name of the VPC. Used as a prefix for all resource naming."
  type        = string

  validation {
    condition     = length(var.vpc_name) > 0 && length(var.vpc_name) <= 64
    error_message = "vpc_name must be between 1 and 64 characters."
  }
}

variable "vpc_cidr" {
  description = "The IPv4 CIDR block for the VPC (e.g. 10.0.0.0/16)."
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block (e.g. 10.0.0.0/16)."
  }
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC."
  type        = bool
  default     = true
}

################################################################################
# Availability Zones
################################################################################

variable "azs" {
  description = "List of availability zone names or suffixes (e.g. [\"us-east-1a\", \"us-east-1b\", \"us-east-1c\"]). Defaults to first 3 AZs in the region."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.azs) <= 6
    error_message = "A maximum of 6 availability zones is supported."
  }
}

################################################################################
# Subnet toggles
################################################################################

variable "enable_public_subnets" {
  description = "Whether to create public subnets. Secure-by-default: disabled."
  type        = bool
  default     = false
}

variable "enable_private_subnets" {
  description = "Whether to create private subnets."
  type        = bool
  default     = true
}

variable "enable_database_subnets" {
  description = "Whether to create dedicated database subnets."
  type        = bool
  default     = false
}

################################################################################
# Subnet CIDRs
################################################################################

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets. Must match the number of AZs when enable_public_subnets is true."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for cidr in var.public_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All public_subnet_cidrs must be valid IPv4 CIDR blocks."
  }
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets. Must match the number of AZs when enable_private_subnets is true."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for cidr in var.private_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All private_subnet_cidrs must be valid IPv4 CIDR blocks."
  }
}

variable "database_subnet_cidrs" {
  description = "List of CIDR blocks for database subnets. Must match the number of AZs when enable_database_subnets is true."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for cidr in var.database_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All database_subnet_cidrs must be valid IPv4 CIDR blocks."
  }
}

################################################################################
# NAT Gateway
################################################################################

variable "enable_nat_gateway" {
  description = "Whether to provision NAT Gateways for private subnet internet access. Requires enable_public_subnets."
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all AZs (cost-saving). When false, one NAT Gateway per AZ is created."
  type        = bool
  default     = true
}

################################################################################
# Flow Logs
################################################################################

variable "enable_flow_logs" {
  description = "Whether to enable VPC Flow Logs to CloudWatch."
  type        = bool
  default     = true
}

variable "flow_log_retention_days" {
  description = "Number of days to retain VPC Flow Logs in CloudWatch."
  type        = number
  default     = 30

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.flow_log_retention_days)
    error_message = "flow_log_retention_days must be a valid CloudWatch Logs retention value (1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653)."
  }
}

################################################################################
# VPC Endpoints
################################################################################

variable "enable_vpc_endpoints" {
  description = "Whether to create common VPC Gateway Endpoints (S3, DynamoDB)."
  type        = bool
  default     = false
}

################################################################################
# Tags
################################################################################

variable "default_tags" {
  description = "Map of default tags to apply to all resources."
  type        = map(string)
  default     = {}
}
