# TODO — terraform-aws-vpc

## Tasks (work in order, check off when complete)

### Core Resources
- [x] 1. Implement public subnets (for_each over AZs, conditional on enable_public_subnets)
- [x] 2. Implement private subnets (for_each over AZs, conditional on enable_private_subnets)
- [x] 3. Implement database subnets (for_each over AZs, conditional on enable_database_subnets)
- [x] 4. Implement internet gateway (conditional on enable_public_subnets)
- [x] 5. Implement EIPs for NAT gateways (conditional on enable_nat_gateway)
- [x] 6. Implement NAT gateways (single or one-per-AZ based on single_nat_gateway)
- [x] 7. Implement public route table + routes (0.0.0.0/0 → IGW)
- [x] 8. Implement private route tables + routes (0.0.0.0/0 → NAT, per-AZ if multi-NAT)
- [x] 9. Implement database route table (no internet route by default)
- [x] 10. Implement all route table associations

### CHECKPOINT — run terraform fmt -recursive && terraform validate. Fix ALL errors before continuing.

### Security Hardening
- [x] 11. Implement default security group (revoke all default rules)
- [x] 12. Implement default NACL with explicit deny-all (override AWS defaults)
- [x] 13. Implement VPC flow logs with CloudWatch log group and IAM role/policy (conditional on enable_flow_logs)
- [x] 14. Implement database subnet group (aws_db_subnet_group, conditional on enable_database_subnets)

### CHECKPOINT — run terraform fmt -recursive && terraform validate. Fix ALL errors before continuing.

### VPC Endpoints & Extras
- [x] 15. Implement gateway VPC endpoints for S3 and DynamoDB (conditional on enable_vpc_endpoints)
- [x] 16. Ensure ALL resources use local.tags for consistent tagging
- [x] 17. Wire up ALL outputs in outputs.tf to actual resource attributes (remove any stubs)

### CHECKPOINT — run terraform fmt -recursive && terraform validate. Fix ALL errors before continuing.

### Testing & Validation
- [x] 18. Write tests/vpc_basic.tftest.hcl — test VPC creation with defaults only
- [x] 19. Write tests/vpc_public.tftest.hcl — test with public subnets and NAT gateway enabled
- [x] 20. Write tests/vpc_complete.tftest.hcl — test with ALL features enabled
- [x] 21. Run terraform test — fix ALL failures until clean
- [x] 22. Run terraform fmt -recursive — ensure no formatting drift
- [x] 23. Run pre-commit run -a — fix ALL hook failures
- [x] 24. Update examples/simple/ to reflect final variable interface
- [x] 25. Update examples/complete/ to reflect final variable interface
- [x] 26. Run terraform validate in examples/simple/
- [x] 27. Run terraform validate in examples/complete/

## Design Requirements
- Secure by default: no public access unless explicitly enabled
- Minimal: no resource created unless its toggle is true
- DRY: for_each over AZs, never copy-paste per-AZ resources
- All resources tagged via merge(local.default_tags, local.resource_tags)
- No hardcoded values anywhere
- Conditional resources use count or for_each with conditional expressions
- NAT gateway: single by default, one-per-AZ optional (for HA)
- Flow logs: enabled by default, CloudWatch destination
- Default SG and NACL: restrictive (deny all)

## Success Criteria (ALL must pass before marking complete)
- [x] terraform validate passes at root
- [x] terraform fmt -recursive produces zero diff
- [x] terraform test passes ALL test files
- [x] pre-commit run -a passes ALL hooks
- [x] Every variable has type + description + validation (where applicable)
- [x] Every output has description and references a real resource attribute
- [x] Zero public resources created when using default variable values
- [x] examples/simple/ passes terraform validate
- [x] examples/complete/ passes terraform validate
- [x] All TODO items above are checked off
