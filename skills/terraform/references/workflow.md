# Workflow and Automation

## Standard Local Workflow

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform apply tfplan
```

Why this sequence:
- `init` prepares providers/modules and backend.
- `fmt` and `validate` catch quality and syntax issues early.
- `plan -out` creates an immutable plan artifact for explicit review.
- `apply tfplan` applies exactly what was reviewed.

## Team or CI Workflow

Plan stage:

```bash
terraform init -input=false
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json
```

Apply stage:

```bash
terraform apply -input=false tfplan
```

Rules:
- Do not re-run `terraform plan` in apply stage for the same deployment decision.
- Keep Terraform and provider versions pinned.
- Review plan output in pull requests before merge/apply.

## Drift Handling

Drift detection without config change:

```bash
terraform plan -refresh-only
```

If drift is expected and should be recorded:

```bash
terraform apply -refresh-only
```

## Destroy Pattern

```bash
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```

Use the same review gate for destroy plans as for normal apply plans.

## Useful Commands

```bash
terraform output
terraform state list
terraform show
terraform workspace list
```
