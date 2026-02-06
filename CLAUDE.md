# CLAUDE.md

## Project

Standalone Terraform module: `terraform-aws-vpc`. One repo, one module, semver tags. Registry-standard (`terraform-<provider>-<name>`).

## CLAUDE.md

## Project
Standalone Terraform module: `terraform-aws-vpc`. One repo, one module, semver tags. Registry-standard (`terraform-<provider>-<name>`).

## Structure
```
.
├── main.tf              # VPC, subnets, gateways, route tables, NACLs
├── variables.tf         # All inputs (typed, described, validated)
├── outputs.tf           # All outputs (described)
├── versions.tf          # Terraform + AWS provider constraints
├── locals.tf            # Computed values, naming, tags
├── data.tf              # Data sources (AZs, caller identity)
├── examples/
│   ├── simple/          # Minimal VPC (private subnets only)
│   └── complete/        # All features enabled
├── tests/               # terraform test (.tftest.hcl)
├── docs/
│   └── testing.md       # Testing patterns and conventions
└── .github/workflows/   # CI pipeline
```

## Commands
```bash
terraform init
terraform fmt -recursive
terraform validate
terraform test                    # native test framework
pre-commit run -a                 # fmt, validate, docs, tflint
```

## Design Rules
- Secure by default: no public subnets unless explicitly enabled
- DRY: use `for_each` over copy-paste; locals for computed values
- Minimal: no resource created unless toggled on
- No hardcoded values: everything parameterized or derived
- Every variable: `type`, `description`, `validation` where applicable
- Every output: `description`
- snake_case everywhere
- Provider constraints: pessimistic `~>`

## Workflow
1. Plan → 2. Implement → 3. Format (`terraform fmt`) → 4. Validate → 5. Test → 6. Commit

## References
- @docs/testing.md
- @.github/workflows/ci.yml
- @.pre-commit-config.yaml