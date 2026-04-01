# Modules and Style

## Minimal Module Layout

```text
my-module/
├── README.md
├── main.tf
├── variables.tf
└── outputs.tf
```

Keep modules focused and reusable. Group logically related resources.

## Variable Patterns

Define type and description for all variables:

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
```

For sensitive inputs:

```hcl
variable "db_password" {
  type      = string
  sensitive = true
}
```

Notes:
- `sensitive = true` hides values in CLI output.
- Sensitive values can still exist in state; secure backend storage is still required.

## Output Patterns

```hcl
output "db_endpoint" {
  value = aws_db_instance.main.endpoint
}

output "api_token" {
  value     = var.api_token
  sensitive = true
}
```

## Module Versioning

- Pin module versions.
- Pin provider versions in `required_providers`.
- Pin Terraform core version via `required_version`.

Example:

```hcl
terraform {
  required_version = ">= 1.6.0, < 2.0.0"
}
```

## Workspace Guidance

Use workspaces for isolated copies of the same stack shape (for example ephemeral environments):

```bash
terraform workspace new feature-123
terraform workspace select feature-123
```

Do not use workspaces as a substitute for strong environment boundaries when environments diverge materially.
