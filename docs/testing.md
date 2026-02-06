# Testing Patterns and Conventions

## Framework

This module uses the [Terraform native test framework](https://developer.hashicorp.com/terraform/language/tests) (`.tftest.hcl` files) introduced in Terraform 1.6.

## Directory Structure

```
tests/
├── vpc_basic.tftest.hcl        # Core VPC resource tests
├── vpc_subnets.tftest.hcl      # Subnet creation and configuration
├── vpc_nat_gateway.tftest.hcl  # NAT gateway provisioning
├── vpc_flow_logs.tftest.hcl    # Flow log configuration
└── vpc_endpoints.tftest.hcl    # VPC endpoint tests
```

## Running Tests

```bash
# Run all tests
terraform test

# Run a specific test file
terraform test -filter=tests/vpc_basic.tftest.hcl

# Verbose output
terraform test -verbose
```

## Test File Structure

Each `.tftest.hcl` file follows this pattern:

```hcl
# Provider configuration for tests
provider "aws" {
  region = "us-east-1"
}

# Variables shared across runs in this file
variables {
  vpc_name = "test-vpc"
  vpc_cidr = "10.0.0.0/16"
}

# Plan-only test (no real infrastructure)
run "validate_vpc_cidr" {
  command = plan

  assert {
    condition     = aws_vpc.this.cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR block does not match expected value."
  }
}

# Apply test (creates real infrastructure, then destroys)
run "create_vpc" {
  command = apply

  assert {
    condition     = aws_vpc.this.enable_dns_support == true
    error_message = "DNS support should be enabled by default."
  }
}
```

## Conventions

### Naming

- Test file names: `<resource_group>.tftest.hcl`
- Run block names: `<verb>_<what>` (e.g., `validate_vpc_cidr`, `create_private_subnets`)

### Test Levels

1. **Plan tests** (`command = plan`): Validate configuration without creating resources. Use for:
   - Input validation
   - Computed value verification
   - Resource count checks
   - Tag verification

2. **Apply tests** (`command = apply`): Create and verify real infrastructure. Use for:
   - Resource attribute verification post-creation
   - Cross-resource dependency validation
   - Integration testing

### Best Practices

- Prefer `plan` tests where possible — they are faster and free
- Use unique CIDR ranges per test file to avoid conflicts in parallel runs
- Always assert on critical attributes: IDs, ARNs, tags
- Test default values explicitly — verify secure defaults are applied
- Test negative cases: ensure resources are NOT created when toggles are off
- Keep test variables minimal — rely on module defaults where possible

### Variable Overrides

Use the `variables` block at the file level for shared values, and per-`run` `variables` for test-specific overrides:

```hcl
variables {
  vpc_name = "test-vpc"
  vpc_cidr = "10.0.0.0/16"
}

run "with_public_subnets" {
  command = plan

  variables {
    enable_public_subnets = true
    public_subnet_cidrs   = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  }

  assert {
    condition     = length(aws_subnet.public) == 3
    error_message = "Expected 3 public subnets."
  }
}
```

### CI Integration

Tests run in CI via GitHub Actions. The workflow:

1. `terraform init`
2. `terraform fmt -check -recursive`
3. `terraform validate`
4. `terraform test` (with AWS credentials via OIDC)

See `.github/workflows/ci.yml` for the full pipeline configuration.
