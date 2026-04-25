---
name: terraform-aws
description: Build, review, and troubleshoot Terraform configurations using the AWS provider. Use for provider setup, authentication patterns, tagging strategy, multi-region usage, import/migration, and AWS-specific safety issues.
---

# Terraform AWS Provider

## Provider Baseline

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

  default_tags {
    tags = {
      Environment = "prod"
      ManagedBy   = "terraform"
    }
  }
}
```

## Multi-Region (v6+)

Prefer top-level `region` on resources/data sources over aliased providers:

```hcl
resource "aws_vpc" "west" {
  region     = "us-west-2"
  cidr_block = "10.1.0.0/16"
}
```

Import in a specific region:

```bash
terraform import aws_vpc.test_vpc vpc-a01106c2@eu-west-1
```

## AWS-Specific Pitfalls

- **IAM propagation delay** — role/policy changes take seconds to propagate; expect transient auth errors after create.
- **Eventual consistency** — "not found" errors immediately after create are normal for IAM, networking, S3.
- **Resource replacement** — immutable attribute changes trigger destroy+create; always review plan for `# forces replacement`.
- **`ignore_changes` drift** — broad ignore masks real drift; scope it narrowly and document why.

## `ignore_tags` for External Controllers

Use when external systems (e.g. Kubernetes) own tag namespaces:

```hcl
provider "aws" {
  ignore_tags {
    key_prefixes = ["kubernetes.io/"]
  }
}
```

## Retry for Transient API Errors

```hcl
provider "aws" {
  region      = "us-east-1"
  max_retries = 25
  retry_mode  = "standard"
}
```
