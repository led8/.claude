# State and Safety

## Remote State First

For teams, use remote backend storage plus locking. Avoid local shared state workflows.

Example remote backend:

```hcl
terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "company"

    workspaces {
      prefix = "my-app-"
    }
  }
}
```

## S3 Locking Patterns

S3 lockfile:

```hcl
backend "s3" {
  bucket       = "example-bucket"
  key          = "path/to/state"
  region       = "us-east-1"
  use_lockfile = true
}
```

S3 with DynamoDB locking:

```hcl
backend "s3" {
  bucket         = "example-bucket"
  key            = "path/to/state"
  region         = "us-east-1"
  dynamodb_table = "TerraformStateLocks"
}
```

## Safety Rules

Do:
- Enforce locking in shared environments.
- Keep credentials in environment variables or managed identity.
- Run `terraform init` after backend changes.
- Review plan files before apply.

Do not:
- Commit `terraform.tfstate*`, `.terraform/`, saved plan files, or sensitive `.tfvars`.
- Use `-lock=false` in team environments.
- Use `terraform force-unlock` unless lock ownership is verified.
- Use `terraform state push` unless break-glass recovery is required.
- Use `-auto-approve` in production without strict control gates.

## Drift and Recovery

Detect drift:

```bash
terraform plan -refresh-only
```

For emergency reconciliation, document:
1. Why drift happened.
2. Whether state or infrastructure should be source of truth.
3. Exact rollback or forward-fix command sequence.
