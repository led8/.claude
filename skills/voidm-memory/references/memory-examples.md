# Memory Examples

## Good memory examples

### Widening Search

```bash
voidm search "oauth refresh" --scope my-repo
voidm search "oauth refresh"
voidm search "auth" --intent "oauth2" --include-neighbors --json
```

Why good: starts local, then widens instead of assuming the repo scope contains everything.

### Constraint

```bash
voidm add "Constraint: the worker queue must not start before schema migration completes. Why it matters: workers deserialize payloads using the latest schema immediately. When it applies: deploys that change job payload shape or dependent tables." --type semantic --scope my-repo
```

### Procedure

```bash
voidm add "Procedure: investigate auth latency by checking Redis health, session validation timing, and fallback behavior in the auth middleware. Why it matters: these are the dominant auth-path failure points in this repo. When it applies: login slowdown, intermittent 401s, and degraded auth performance." --type procedural --scope my-repo
```

### Architecture

```bash
voidm add "Architecture: the dashboard read path goes through API cache first, then read replicas, then primary fallback. Why it matters: latency and stale-data debugging must follow this order. When it applies: cache correctness, read latency, and replica lag investigations." --type conceptual --scope my-repo
```

### Decision

```bash
voidm add "Decision: keep TypeScript as the primary language for feature work in this repo. Why it matters: the tooling, review workflow, and existing modules assume TypeScript-first changes. When it applies: new feature implementation and refactor planning." --type semantic --scope my-repo
```

### Preference

```bash
voidm add "Preference: for non-trivial tasks in this repo, produce a detailed numbered plan with validation checkpoints and wait for explicit approval before editing files. Why it matters: this matches the user's preferred working style and improves control over larger changes. When it applies: feature work, refactors, architecture changes, and non-trivial debugging." --type semantic --scope my-repo
```

### Tagged And Linked Insert

```bash
voidm add "Procedure: retry OAuth refresh with jittered backoff before failing the CLI login flow. Why it matters: transient 401s are often recoverable. When it applies: token refresh failures in auth flows." \
  --type procedural \
  --scope my-repo \
  --tags "oauth2,jwt,auth,cli" \
  --link <auth-constraint-id>:SUPPORTS
```

Why good: adds stable user tags and an explicit semantic link instead of relying only on generic auto-linking.

## Good learning-tip examples

### Recovery Tip

```bash
voidm learn add "Use jittered retries when OAuth refresh gets a transient 401." \
  --category recovery \
  --trigger "transient 401 during token refresh" \
  --application-context "OAuth2 token refresh flow" \
  --task-category authentication \
  --source-outcome recovered_failure \
  --trajectory traj-auth-20260316-01 \
  --scope my-repo
```

### Strategy Tip

```bash
voidm learn add "Read the existing code path before editing when fixing a non-trivial repo-specific bug." \
  --category strategy \
  --trigger "bug fix in existing code" \
  --application-context "debugging an established codebase" \
  --task-category debugging \
  --source-outcome success \
  --trajectory traj-debug-20260320-01 \
  --scope my-repo
```

### Preview Ingest First

```bash
voidm learn ingest --from trajectory.json --dry-run --json
```

### Persist Extracted Tips

```bash
voidm learn ingest --from trajectory.json --write --scope my-repo --json
```

### Search Only Learning Tips

```bash
voidm learn search "oauth refresh" --category recovery --task-category authentication --scope my-repo --json
```

### Consolidate Overlapping Tips

```bash
voidm learn consolidate --scope my-repo --dry-run --json
```

## Good ontology examples

### Create Concept And Attach Memory

```bash
voidm ontology concept add "AuthService" --description "Handles JWT + OAuth2 flows" --scope my-repo
voidm ontology link <memory-id> --from-kind memory INSTANCE_OF <concept-id> --to-kind concept
```

Why good: turns a recurring component into a reusable class for graph retrieval.

### Preview Batch Enrichment

```bash
voidm ontology enrich-memories --scope my-repo --dry-run
```

Why good: previews entity-to-concept enrichment before writing.

## Bad memory examples

### Task log

```bash
voidm add "Fixed login bug today" --type semantic --scope my-repo
```

Why bad: this is history, not reusable knowledge.

### Temporary task

```bash
voidm add "Need to implement pagination next" --type semantic --scope my-repo
```

Why bad: this belongs in a plan or backlog, not long-term memory.

### Raw output

```bash
voidm add "npm test passed with 238 tests" --type semantic --scope my-repo
```

Why bad: ephemeral execution detail.

### Raw trajectory recap

```bash
voidm learn add "Tried three fixes and the second one worked." \
  --category strategy \
  --trigger "debugging" \
  --application-context "repo work" \
  --task-category debugging \
  --source-outcome success \
  --trajectory traj-debug-01 \
  --scope my-repo
```

Why bad: still a session recap, not a generalized reusable tip.

### Repo-only tunnel vision

```bash
voidm search "oauth refresh" --scope my-repo
voidm search "oauth refresh" --scope my-repo --json
voidm search "oauth refresh" --scope my-repo --limit 20
```

Why bad: repeats the same local fence instead of widening when recall is sparse.

### Untagged and unlinked durable memory

```bash
voidm add "Procedure: retry OAuth refresh with jittered backoff before failing the CLI login flow." --type procedural --scope my-repo
```

Why bad: misses stable tags and an obvious semantic link that would improve retrieval.

## Search-before-add examples

### Narrow then broad

```bash
voidm search "hydration bug" --scope my-repo
voidm search "context initialization rendering"
voidm search "hydration" --intent "react rendering" --include-neighbors --json
```

### Learning-tip recall

```bash
voidm learn search "token refresh" --category recovery --task-category authentication --scope my-repo --json
```

### Architectural recall

```bash
voidm search "architecture" --scope my-repo
voidm search "auth service dependencies" --scope my-repo --json
```

### Preference recall

```bash
voidm search "user preference" --scope my-repo
voidm search "approval before editing files" --scope my-repo --json
```

### Linking examples

```bash
voidm link <decision-id> SUPPORTS <constraint-id>
voidm link <runbook-id> DERIVED_FROM <incident-pattern-id>
voidm link <component-id> PART_OF <subsystem-id>
voidm link <id1> RELATES_TO <id2> --note "both affect deployment ordering"
```
