# Architecture Notes

This summary is intentionally practical. Use it when troubleshooting non-obvious Terraform behavior.

## Execution Model

- Terraform builds a directed acyclic graph (DAG) from configuration, state, and dependencies.
- Independent nodes execute in parallel.
- Dependency edges enforce ordering.

Debug tip:

```bash
terraform graph -type=plan | dot -Tpng > graph.png
```

## Plan vs Apply

- `terraform plan` computes proposed changes without mutating infrastructure.
- `terraform apply` executes a plan and updates state.
- Applying a saved plan file prevents plan drift between approval and execution.

## State Model

- State maps resource addresses to real-world objects.
- Backends provide storage and locking mechanics.
- Incorrect state operations can cause destructive outcomes; prefer normal plan/apply workflows.

## Provider Interaction

- Terraform Core delegates resource CRUD logic to provider plugins.
- Providers return current state and proposed changes to Core during plan/apply.
- Version pinning limits unexpected provider behavior changes.

## Modules and Evaluation

- Modules are loaded recursively and combined into a single evaluated configuration graph.
- Expressions, references, and `count`/`for_each` expansion affect graph shape.
- Unknown values at plan time can defer or limit complete change calculation.
