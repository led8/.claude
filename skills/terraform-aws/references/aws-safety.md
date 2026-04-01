# AWS Safety and Failure Modes

## Common Failure Modes

- IAM propagation delay after role/policy changes.
- Eventual consistency causing temporary "not found" after create.
- Resource replacement surprises for immutable attributes.
- Hidden drift caused by broad `ignore_changes`.
- Concurrent apply attempts without proper state locking.

## Do

- Use role-based auth and explicit provider configuration per environment.
- Keep plan review mandatory in production.
- Expect eventual consistency around IAM/networking and design safe retries/timeouts.
- Use `create_before_destroy` where replacement would break availability.
- Use `terraform plan -refresh-only` to inspect drift before corrective changes.

## Do Not

- Do not hardcode credentials in HCL.
- Do not overuse `ignore_changes`; treat it as exception handling.
- Do not use `-auto-approve` in production without strong gate controls.
- Do not run concurrent applies on the same state.

## Targeted `ignore_changes` Pattern

Use only when an external controller owns an attribute:

```hcl
resource "aws_dynamodb_table" "example" {
  name         = "my-table"
  billing_mode = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5

  lifecycle {
    ignore_changes = [read_capacity, write_capacity]
  }
}
```

Document ownership of ignored attributes in module README or code comments.
