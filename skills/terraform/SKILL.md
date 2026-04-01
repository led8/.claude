---
name: terraform
description: Build, review, and troubleshoot Terraform configurations and workflows. Use for Terraform CLI usage, module design, backend/state strategy, drift handling, and safe plan/apply patterns.
---

# Terraform

Use this skill when the request involves Terraform code, module design, state/backends, plan/apply workflows, or Terraform troubleshooting.

## Quick Start

Use this baseline sequence for most Terraform changes:

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

For drift checks:

```bash
terraform plan -refresh-only
```

For controlled teardown:

```bash
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```

## Workflow Routing

- New or updated infrastructure: read `references/workflow.md`.
- Module design, inputs/outputs, and style: read `references/modules-and-style.md`.
- State backend, locking, or safety concerns: read `references/state-and-safety.md`.
- Why Terraform behaves this way (graph/state/provider internals): read `references/architecture.md`.

## Core Rules

1. Always review a plan before apply.
2. In automation, apply a saved plan file (`terraform apply tfplan`), not an implicit re-plan.
3. Prefer remote state with locking in team environments.
4. Never commit `.terraform/`, `terraform.tfstate*`, `.terraform.tfstate.lock.info`, saved plans, or sensitive `.tfvars`.
5. Treat `terraform force-unlock` and `terraform state push` as break-glass operations.
6. Avoid routine `-target` usage; use full graph operations unless doing emergency recovery.

## Common Patterns

### Create or modify infrastructure

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform apply tfplan
```

### Bring existing resources under Terraform

```bash
terraform import <resource_address> <real_world_id>
terraform plan
```

### Work with workspaces

```bash
terraform workspace list
terraform workspace new dev
terraform workspace select dev
```

### Inspect dependencies for debugging

```bash
terraform graph -type=plan | dot -Tpng > graph.png
```

## Documentation Sources

- DeepWiki source repo for architecture grounding: `hashicorp/terraform`.
