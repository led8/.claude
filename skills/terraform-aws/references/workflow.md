# Terraform AWS Workflow

## Standard Change Flow

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform apply tfplan
```

In CI:
- Keep plan and apply as separate stages.
- Apply only the reviewed plan artifact.

## Data Sources vs Resources

- `data` blocks: read existing AWS information for decisions.
- `resource` blocks: create/manage lifecycle.

Example:

```hcl
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "logs" {
  bucket = "my-example-logs-bucket"
}
```

## Multi-Region Strategy (v6+)

Primary pattern:
- Single provider config with default region.
- Set `region` argument on individual resources/data sources when needed.

Example:

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "peer" {
  region     = "us-west-2"
  cidr_block = "10.1.0.0/16"
}
```

## Import and Migration

Import existing infrastructure:

```bash
terraform import aws_vpc.test_vpc vpc-a01106c2@eu-west-1
```

Migration guidance:
1. Import into clearly defined addresses.
2. Run plan and reconcile drift before broader changes.
3. Avoid mixing large imports with unrelated feature changes in one apply.
