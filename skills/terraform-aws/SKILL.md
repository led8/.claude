---
name: terraform-aws
description: Build, review, and troubleshoot Terraform configurations using the AWS provider. Use for provider setup, authentication patterns, tagging strategy, multi-region usage, import/migration, and AWS-specific safety issues.
---

# Terraform AWS Provider

Use this skill for Terraform tasks that are specifically about AWS provider behavior or AWS resource patterns.

## Quick Start

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

Then use the standard flow:

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

## Workflow Routing

- Auth, profiles, role assumption, and tagging: `references/provider-auth-tags.md`
- Day-to-day Terraform AWS workflow and imports: `references/workflow.md`
- AWS-specific failure modes and safety guardrails: `references/aws-safety.md`
- Provider architecture and lifecycle internals: `references/architecture.md`

## Core Rules

1. Do not hardcode AWS credentials in `.tf` files.
2. Pin AWS provider versions and review provider upgrades explicitly.
3. Always review plan output before apply, especially for replacement actions.
4. Prefer saved plans in automation (`terraform apply tfplan`).
5. Use `default_tags` for global tags; use resource tags only for overrides.
6. Use `ignore_changes` narrowly and document why each ignored field is external.
7. Treat `terraform import` and state operations as controlled migrations, not routine edits.

## Common Patterns

### Multi-region (AWS provider v6+)

Prefer top-level `region` on resources/data sources instead of many aliased providers when possible.

```hcl
resource "aws_vpc" "west" {
  region     = "us-west-2"
  cidr_block = "10.1.0.0/16"
}
```

### Import in a specific region

```bash
terraform import aws_vpc.test_vpc vpc-a01106c2@eu-west-1
```

### Data source + resource composition

```hcl
data "aws_regions" "all" {
  all_regions = true
}
```

Use data sources for lookup/read; use resources for lifecycle management.

## Documentation Sources

- DeepWiki architecture and provider internals: `hashicorp/terraform-provider-aws`
