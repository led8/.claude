---
name: voidm-memory
description: Use local cli-based persistent memory and trajectory-informed learning tips with voidm for coding and repository work.
---

# Voidm Memory

## Core Rules

1. Local `voidm` CLI only.
2. Search before adding — always, both lanes.
3. Scope by repo root name only.
4. Store durable knowledge only — no task logs, recaps, or temp notes.
5. `--dry-run` before any `--write` (ingest, consolidate).
6. `voidm recall` for startup — one call, not five manual searches.
7. `--agent` flag when operating as a coding agent.

## Two Lanes — Decide First

| Lane | Command | Store when… |
|---|---|---|
| **Memory** | `voidm add` | the knowledge explains how this repo works |
| **Tips** | `voidm learn` | the knowledge is a reusable tactic from a real agent run |

Never replace architectural memory with learning tips. Never put repo facts into the tips lane.

## Scope

```bash
voidm scope detect                    # auto-detect from git remote
eval "$(voidm scope detect --export)" # sets VOIDM_SCOPE=my-repo
```

Do not create subscopes (branches, tickets, dates). One scope per repo root.

## Agent Mode

```bash
export VOIDM_AGENT_MODE=1   # set once per session
voidm recall --scope my-repo --agent
voidm search "auth" --scope my-repo --agent --json
```

`--agent` produces compact token-minimal JSON. Combine with `--json` for maximum compatibility.

---

## LANE 1 — Memory (`voidm add`)

### Startup Recall

```bash
voidm recall --scope my-repo           # 5-category structured digest
voidm recall --scope my-repo --also "auth" --also "redis"  # + task terms
```

Then 1–3 task-specific searches:

```bash
voidm search "deployment order" --scope my-repo --json
voidm search "auth" --intent "oauth2" --include-neighbors --json
```

Widen when scoped results are thin — drop `--scope` or add `--intent`.

**Run recall before:** entering a repo, planning a feature, debugging non-trivial issues, touching auth/storage/migrations/CI/deployment.

### Memory Eligibility Test

Add only when **all** are true:
  •	durable (still useful in two weeks)
  •	reusable (not locked to one session)
  •	non-trivial (not a generic truism)
  •	specific enough to act on later
  •	not already covered (searched first)

If any answer is weak, do not store.

### What Not To Store

Never store: task logs · session summaries · "fixed X today" · temp checklists · raw output · trajectory dumps · one-off traces · unvalidated speculation.

```bash
# Bad — history, not knowledge
voidm add "Fixed login bug today" --type semantic --scope my-repo
```

### What To Store

Architectural relationships · stable constraints · design decisions + rationale · debugging runbooks · deployment/migration procedures · durable user preferences · lessons that generalize beyond one incident.

```bash
voidm add "Constraint: migrations must complete before worker rollout. Why it matters: workers assume the new schema immediately. When it applies: any deploy that changes schema used by async jobs." \
  --type semantic --scope my-repo

voidm add "Architecture: read path flows through API cache → read replicas → primary fallback. Why it matters: latency debugging must follow this order. When it applies: cache and performance issues." \
  --type conceptual --scope my-repo
```

### Memory Types

| Type | Use for |
|---|---|
| `semantic` | constraints, decisions, stable facts, preferences |
| `procedural` | runbooks, debugging workflows, deployment sequences |
| `conceptual` | architecture, component relationships, system boundaries |

### Writing Pattern

Structure every memory as: **Label: core statement. Why it matters: reason. When it applies: scope.**

```text
Procedure: debug hydration issues by checking markup parity, early browser API usage, and context initialization order. Why it matters: these are the three highest-frequency causes. When it applies: SSR or client hydration mismatches.
```

Rewrite events into lessons before storing:
  - "Fixed Docker build bug" → "Procedure: when base image changes, force clean rebuild to avoid misleading stale cache."

### Search-Before-Add Protocol

1. Search narrow (`voidm search "hydration bug" --scope my-repo`)
2. Search broad (`voidm search "context initialization rendering" --scope my-repo`)
3. If covered → do not add. Extend with `voidm update <id>` if close.
4. Add only when meaningfully distinct.

### Duplicate Handling

  •	Prefer `voidm update <id>` over delete+re-add (preserves graph edges and ID)
  •	Link instead of restate when the relationship is the useful part
  •	Check `voidm add` suggested links before writing manual ones

### Linking

Bias toward explicit links. If two memories reason well together, they deserve an edge.

Prefer `SUPPORTS`, `DERIVED_FROM`, `PART_OF` over `RELATES_TO` (requires `--note`).

```bash
voidm add "..." --type procedural --scope my-repo --link <constraint-id>:SUPPORTS
voidm link <decision-id> SUPPORTS <constraint-id>
voidm why <id>  # inspect existing edges before adding redundant links
```

### Tags and Ontology

Add `--tags` for stable labels: subsystem names, protocols, libraries, incident labels.

```bash
voidm add "..." --type procedural --scope my-repo --tags "oauth2,jwt,auth,cli"
```

Promote recurring components to ontology concepts when multiple memories share the concept:

```bash
voidm ontology concept add "AuthService" --description "Handles JWT + OAuth2 flows" --scope my-repo
voidm ontology link <memory-id> --from-kind memory INSTANCE_OF <concept-id> --to-kind concept
voidm ontology enrich-memories --scope my-repo --dry-run
```

### Conflict Awareness

JSON search output includes a `"conflicts"` field. When non-empty:
  •	surface the conflict to the user
  •	run `voidm why <id>` on each conflicting memory
  •	decide: update one, delete one, or add a `CONTRADICTS` edge

```bash
voidm search "auth" --scope my-repo --json   # check "conflicts" field
voidm why <id> --json                         # inspect provenance before acting
```

### Staleness and Updates

```bash
voidm stale --scope my-repo --older-than 60 --json  # find aging memories
voidm update <id> --content "revised"               # patch in place (preserves edges)
voidm update <id> --importance 9 --tags "auth,retry"
```

Use `voidm update` over delete+re-add when the memory has graph edges. Run `voidm stale` at extraction moments.

---

## LANE 2 — Learning Tips (`voidm learn`)

### `learn add` vs `learn ingest`

**Use `learn add`** when you know exactly what the tactic is and have the trajectory ID.

**Use `learn ingest`** when you have a full trajectory JSON and want `voidm` to propose candidates.

**Never skip `--dry-run`** before `--write`.

### Tip Eligibility Test

Write a tip only when **all** are true:
  •	it is a **tactic** (action to take), not a fact (state of the world)
  •	backed by a **real trajectory ID** — mandatory, not optional
  •	trigger is **narrow** — fires on a specific condition, not every task
  •	application_context is **specific** — not "any codebase"
  •	searched first with `voidm learn search` — not a duplicate

### What Not To Store As A Tip

  •	repo facts → use `voidm add` instead
  •	session recaps ("fixed bug with retry") → rewrite or discard
  •	generic truisms ("always test before committing") → too broad
  •	tips without a real trajectory ID
  •	duplicates of existing tips → consolidate instead

### Tip Quality Standard

The `trigger` and `application_context` control when a tip fires — get them wrong and it fires everywhere or never.

| Field | Bad | Good |
|---|---|---|
| `trigger` | `"debugging"` | `"cargo build fails at link time after cargo check passes"` |
| `application_context` | `"any codebase"` | `"Rust CLI on macOS with native dependencies"` |
| `content` | `"I ran check first and it helped"` | `"Run cargo check before build to isolate compile from link errors."` |

### Search-Before-Learn Protocol

1. `voidm learn search "<trigger keywords>" --scope my-repo`
2. `voidm learn search "<keywords>" --category recovery --json`
3. Widen if thin: drop `--scope`
4. If covered → do not add. If close → add with distinct trigger, then consolidate.

### Tip Duplicate Handling and Consolidation

Run `voidm learn consolidate` after every ingest write session, and when `voidm learn search` returns 3+ similar tips.

```bash
voidm learn consolidate --scope my-repo --dry-run --json  # always dry-run first
voidm learn consolidate --scope my-repo --json
```

---

## Utility Commands

```bash
# Batch add memories from JSON
voidm batch-add --from memories.json --json

# Per-scope stats
voidm stats --scope my-repo --json

# Staleness review
voidm stale --scope my-repo --older-than 60 --json
```

---

## Command Recipes

### Startup

```bash
voidm scope detect
voidm recall --scope my-repo --agent
voidm search "specific topic" --scope my-repo --json
```

### Memory Add

```bash
voidm add "Constraint: auth requests fail closed when Redis is unavailable. Why it matters: degraded Redis causes auth instability. When it applies: auth-path changes." \
  --type semantic --scope my-repo --tags "auth,redis"

voidm add "Procedure: retry OAuth refresh with jittered backoff before failing. Why it matters: transient 401s are recoverable. When it applies: token refresh failures." \
  --type procedural --scope my-repo --tags "oauth2,auth,cli" --link <auth-constraint-id>:SUPPORTS
```

### Memory Update and Provenance

```bash
voidm update <id> --content "revised" --importance 9
voidm why <id> --json
```

### Learn — Add (manual)

```bash
voidm learn search "cargo link error" --category recovery --scope my-repo --json

voidm learn add "When cargo check passes but cargo build fails at link time, check system libraries before touching Rust code." \
  --category recovery \
  --trigger "cargo build fails at link time after cargo check passes" \
  --application-context "Rust CLI projects on macOS with native dependencies" \
  --task-category debugging \
  --source-outcome recovered_failure \
  --trajectory traj-voidm-build-20260403-01 \
  --scope my-repo
```

### Learn — Ingest (3-step workflow)

```bash
# 1. Dry-run — always
cat trajectory.json | voidm learn ingest --stdin --dry-run --json

# 2. Write after reviewing candidates
cat trajectory.json | voidm learn ingest --stdin --write --scope my-repo --json

# 3. Consolidate after every write session
voidm learn consolidate --scope my-repo --dry-run --json
voidm learn consolidate --scope my-repo --json
```

### Learn — Search and Inspect

```bash
voidm learn search "token refresh" --category recovery --task-category authentication --scope my-repo --json
voidm learn get <id> --json
```

### Graph and Ontology

```bash
voidm link <decision-id> SUPPORTS <constraint-id>
voidm link <runbook-id> DERIVED_FROM <incident-id>
voidm ontology concept add "AuthService" --description "Handles JWT + OAuth2" --scope my-repo
voidm ontology enrich-memories --scope my-repo --dry-run
```

---

## Decision Heuristic

### Before `voidm add`:
  •	is this durable, reusable, and specific enough to act on?
  •	did I search first? does `voidm update` cover it instead?
  •	is this a tactic from a run? → use `voidm learn` instead

### Before `voidm learn add`:
  •	is this a tactic, not a fact? backed by a real trajectory ID?
  •	is the trigger narrow? is the context specific?
  •	did I run `voidm learn search` first?
  •	is this better as a `voidm add` memory instead?

---

## Default Behavior

1. `voidm scope detect` if scope not known
2. `voidm recall --scope my-repo --agent` for structured startup
3. Widen search beyond scope when scoped results are thin
4. Check `"conflicts"` in search JSON; run `voidm why` on flagged IDs before acting
5. Choose lane: `voidm add` for repo knowledge, `voidm learn` for run-derived tactics
6. Search before writing — both lanes
7. Prefer `voidm update` when extending an existing memory
8. Dry-run before any ingest write; consolidate after every ingest write session
9. Add tags manually when stable labels are obvious; create explicit links over auto-links
10. At extraction moments: run `voidm stale --scope my-repo` before adding new memories
