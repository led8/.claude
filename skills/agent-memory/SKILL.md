---
name: agent-memory
description: Use local shell commands to operate Neo4j Agent Memory for coding-agent workflows with task-scoped sessions, concise reasoning traces, and review-first durable memory.
---

# Agent Memory

## Core Rules

1. Use local shell commands only. Do not assume direct Python object access.
2. Keep Neo4j running locally before memory work.
3. Use one `session_id` per active coding task.
4. Treat every user turn and every assistant final response as a memory checkpoint. Decide explicitly whether to read, write, update, or skip.
5. Write `short-term` selectively for the active task stream.
6. Open `reasoning` traces only for non-trivial work.
7. Treat `long-term` memory as review-first. Propose before persisting.
8. Use `replace-fact` and `replace-preference` for durable modification. Obsolescence should create a new active entry and supersede the old one.
9. Treat `delete` as cleanup, not as the normal obsolescence path for durable memory.
10. Delete only by explicit UUID after inspection.
11. Reuse exact same-name same-type entities first. Let resolution and deduplication handle fuzzy variants.
12. Use `update-entity` for same-identity corrections, `alias-entity` for alternate names, and `merge-entity` for duplicate nodes that represent the same real thing.
13. Do not emulate entity edits with delete and re-add unless the old entry is clearly wrong and should be cleaned up.

## Reporting Contract

Memory use must be observable by the user.

At every memory checkpoint, emit one short line that states:
- the memory action taken: `recall`, `search`, `get-context`, `short-term write`, `reasoning update`, `durable review`, or `skip`
- the reason for that decision

Examples:
- `memory: recall — startup for a non-trivial repo task`
- `memory: search — checking for an existing durable fact before writing`
- `memory: short-term write — the new user constraint may matter later in this task`
- `memory: skip — no useful continuity and no durable signal`

After any actual memory tool call, emit one short result line:
- `memory result: recalled 2 relevant facts`
- `memory result: no relevant memory found`
- `memory result: stored short-term message`
- `memory result: durable candidate reviewed, no write`
- `memory result: skipped`

Rules:
- never claim a memory action succeeded unless it actually succeeded
- if a memory action fails, say so briefly
- keep reporting short and factual
- do not expose secrets, raw credentials, or unnecessary raw tool output

## Command Surface

Use the `memory` CLI group:

```bash
neo4j-agent-memory memory --local-embedder <command> ...
```

Connection can come from shell configuration or explicit flags on the `memory` group:
- `--uri`
- `--user`
- `--password`
- `--database`

Use `--local-embedder` for the best local coding workflow. It uses the local
`sentence-transformers` provider with `BAAI/bge-small-en-v1.5`.

Use `--hashed-local-embedder` only as a fallback when you deliberately need the
older deterministic hashed embedder.

## Three Memory Layers

### Short-Term

Use `short-term` for the active task stream:
- current user requests
- current assistant replies
- session-local observations needed during the task
- a few key tool-facing observations when they help the next step

Operational commands:
- `add-message`
- `delete-message`

Do not dump every shell command, every raw output block, or noisy scratch notes into
`short-term`.

### Reasoning

Use `reasoning` for non-trivial tasks:
- concise reusable trace steps
- tool calls and outcomes
- final success or failure summaries

Operational commands:
- `start-trace`
- `add-trace-step`
- `add-tool-call`
- `complete-trace`

Do not store noisy intermediate thinking.

### Long-Term

Use `long-term` only for durable knowledge that should survive the task:
- `facts` for stable repo truths, constraints, and decisions
- `preferences` for durable workflow or communication preferences
- `entities` for important nouns worth linking and retrieving later

Operational commands:
- `add-fact`
- `add-preference`
- `add-entity`
- `update-entity`
- `alias-entity`
- `merge-entity`
- `replace-fact`
- `replace-preference`
- `inspect`
- `search`
- `delete`

This layer is curated. In V1 it is review-first, not automatic.

## Standard Workflow

1. Start Neo4j locally.
2. Build a task-scoped `session_id`.
3. Run startup recall for the task session.
4. Treat startup and session end as anchors, not as the only memory moments.
5. On every user turn, decide whether to use `recall`, `search`, or `get-context`, and whether to add the user turn to `short-term`.
6. Start a `reasoning` trace if the task is multi-step, uncertain, or tool-heavy.
7. On meaningful execution steps, decide whether to add a trace step or tool call.
8. Before every assistant final response, decide whether to add the assistant turn to `short-term`, update reasoning, inspect or search for validation, or prepare a durable candidate.
9. When durable knowledge becomes clear, prepare a `long-term` candidate.
10. Review the candidate with the standard review block.
11. Persist the reviewed candidate with `add-fact`, `add-preference`, or `add-entity`.
12. If a durable fact or preference changes or becomes obsolete, use `replace-fact` or `replace-preference`.
13. If an entity needs a same-identity correction, use `update-entity`. If it needs another name, use `alias-entity`. If two nodes represent the same entity, use `merge-entity`.
14. Use `inspect`, `search`, `recall`, and `get-context` to validate and retrieve memory.
15. At session end or a meaningful stopping point, decide whether to `complete-trace`.
16. Use `delete` or `delete-message` only after explicit inspection and confirmation.
17. For durable memory, use `delete` only for cleanup of clearly wrong, duplicate, parasite, or test-only entries.

## Turn-Based Decision Checkpoints

At each checkpoint, decide whether memory use is needed. This is not a mandatory write.

### On Every User Turn

- decide whether startup recall is enough or whether you need `search` or `get-context`
- decide whether the new user turn should be added to `short-term`
- decide whether the task now warrants opening or updating a `reasoning` trace

### Before Every Assistant Final Response

- decide whether the assistant turn should be added to `short-term`
- decide whether the trace needs a new step, tool call, or completion
- decide whether a durable `fact`, `preference`, or `entity` candidate emerged

### At Session Start And Session End

- at session start, run `recall` for the task-scoped session
- at session end or a meaningful pause, review whether `complete-trace` and a durable-memory review are appropriate

## Startup And Session Commands

Start Neo4j:

```bash
docker compose -f docker-compose.test.yml up -d
```

**The repo provides a local `.env.test` and `docker-compose.test.yml`, so read `NEO4J_TEST_PASSWORD`, preload the shell for memory commands with:**

```bash
set -a; source .env.test; set +a; NEO4J_PASSWORD="$NEO4J_TEST_PASSWORD"
```

Use this prefix only for repos that actually follow that test-password pattern.

Build a task-scoped session:

```bash
set -a; source .env.test; set +a; NEO4J_PASSWORD="$NEO4J_TEST_PASSWORD" \
  neo4j-agent-memory memory --local-embedder session-id \
  --repo agent-memory \
  --task "debug extraction"
```

The returned `session_id` is the handle for the active coding task.

Assemble startup recall for that task:

```bash
set -a; source .env.test; set +a; NEO4J_PASSWORD="$NEO4J_TEST_PASSWORD" \
  neo4j-agent-memory memory --local-embedder recall \
  --repo agent-memory \
  --task "debug extraction" \
  --session-id "coding/agent-memory/debug-extraction/run-1"
```

## Short-Term Commands

Add the current user or assistant turn:

```bash
neo4j-agent-memory memory --local-embedder add-message \
  --session-id "coding/agent-memory/debug-extraction/run-1" \
  --role user \
  "Investigate why extracted entities are not linked."
```

Delete a short-term message only by UUID:

```bash
neo4j-agent-memory memory --local-embedder delete-message --id <message-uuid>
```

## Reasoning Commands

Start a trace:

```bash
neo4j-agent-memory memory --local-embedder start-trace \
  --session-id "coding/agent-memory/debug-extraction/run-1" \
  --task "debug entity linking"
```

Add a reasoning step:

```bash
neo4j-agent-memory memory --local-embedder add-trace-step \
  --trace-id <trace-uuid> \
  --thought "Check whether the message links to the persisted entity id." \
  --action "Inspect short-term entity linking logic."
```

Record a tool call:

```bash
neo4j-agent-memory memory --local-embedder add-tool-call \
  --step-id <step-uuid> \
  --tool-name rg \
  --arguments-json "{\"pattern\":\"MENTIONS\",\"path\":\"src\"}" \
  --result-text "Found short-term linking query." \
  --auto-observation
```

Complete the trace:

```bash
neo4j-agent-memory memory --local-embedder complete-trace \
  --trace-id <trace-uuid> \
  --outcome "Confirmed the persisted entity id must be reused after MERGE." \
  --success
```

## Long-Term Candidate Review

Use this exact structure before any durable write:

```text
[Long-term candidate]
type: <fact|preference|entity>
scope: <repo|personal>
content: <durable memory candidate>
why: <why this is durable and reusable>
source: <user_explicit|code_verified|docs_verified|test_verified|run_observation>
confidence: <high|medium|low>
evidence: <short concrete evidence>
suggested_action: <remember_fact|remember_preference|remember_entity>
decision_needed: persist | ignore
```

A candidate is valid only when:
- the source is identifiable
- the information is likely durable beyond the current task
- the information is reusable by a future coding run
- the memory type is clear

`confidence` is a policy signal:
- `high`: durable, reusable, and backed by a strong source
- `medium`: promising but still mainly observation-driven
- `low`: too temporary or ambiguous to store

Use empirical discoveries when they are validated:
- a bug was reproduced, fixed, and verified
- repository behavior was confirmed by code or rerun
- a pattern worked better than the docs and the mismatch was confirmed
- an observation held across multiple runs

Practical rule:
- single observation: usually `medium`
- reproduced bug plus verified fix: often `high`
- doc mismatch: becomes `high` only after actual repo behavior is confirmed

### Durable Write Commands

Persist a reviewed fact:

```bash
neo4j-agent-memory memory --local-embedder add-fact \
  --repo agent-memory \
  --task "debug extraction" \
  --subject "Short-term extraction" \
  --predicate "linking_rule" \
  --object-value "must use persisted entity id returned after Neo4j MERGE"
```

Persist a reviewed preference:

```bash
neo4j-agent-memory memory --local-embedder add-preference \
  --repo agent-memory \
  --task "skill design" \
  --category workflow \
  --preference "Prefer explicit CLI CRUD operations" \
  --context "agent-memory skill"
```

Persist or reuse a curated entity:

```bash
neo4j-agent-memory memory --local-embedder add-entity \
  --repo agent-memory \
  --task "skill design" \
  --name "GLiNER" \
  --type OBJECT \
  --description "Local entity extraction component"
```

Facts and preferences are idempotent in the same durable scope. Replaying the same add command should reuse the existing active durable entry instead of creating a duplicate.

### Durable Modification Commands

When a fact changes or becomes obsolete, create a new active fact and supersede the old one:

```bash
neo4j-agent-memory memory --local-embedder replace-fact \
  --id <fact-uuid> \
  --object-value "must use the persisted entity id returned by Neo4j after MERGE"
```

When a preference changes or becomes obsolete, create a new active preference and supersede the old one:

```bash
neo4j-agent-memory memory --local-embedder replace-preference \
  --id <preference-uuid> \
  --preference "Prefer explicit CLI memory CRUD commands"
```

For same-identity entity corrections, keep the existing entity and update its canonical fields:

```bash
neo4j-agent-memory memory --local-embedder update-entity \
  --id <entity-uuid> \
  --name "Neo4j Agent Memory" \
  --description "Graph-native agent memory package"
```

If you discover another valid name for the same entity, add it as an alias:

```bash
neo4j-agent-memory memory --local-embedder alias-entity \
  --id <entity-uuid> \
  --alias "agent-memory"
```

If two entity nodes are duplicates of the same real thing, merge the duplicate into the canonical node:

```bash
neo4j-agent-memory memory --local-embedder merge-entity \
  --source-id <duplicate-entity-uuid> \
  --target-id <canonical-entity-uuid>
```

Use `delete --kind entity --id <entity-uuid>` only when the entity is clearly wrong, duplicate test noise, or otherwise needs cleanup rather than correction.

## Retrieval And Review Commands

Inspect one entry by UUID:

```bash
neo4j-agent-memory memory --local-embedder inspect --kind fact --id <fact-uuid>
```

Search a layer:

```bash
neo4j-agent-memory memory --local-embedder search \
  --kind fact \
  --query "persisted entity id" \
  --threshold 0.0
```

Assemble combined context:

```bash
neo4j-agent-memory memory --local-embedder get-context \
  --session-id "coding/agent-memory/debug-extraction/run-1" \
  --query "How should I handle durable coding-agent memory from the shell?"
```

## Deletion Rules

Delete only after inspection and only by explicit UUID.

For durable memory, `delete` is a cleanup operation:
- use `replace-fact` and `replace-preference` when a durable fact or preference becomes obsolete
- use `update-entity`, `alias-entity`, and `merge-entity` for entity maintenance before considering `delete`
- use `delete` only when an entry is clearly wrong, duplicate, parasite, or test-only
- do not use `delete` as the normal history-preserving path for durable memory changes

Delete durable memory:

```bash
neo4j-agent-memory memory --local-embedder delete --kind fact --id <fact-uuid>
```

Delete short-term memory:

```bash
neo4j-agent-memory memory --local-embedder delete-message --id <message-uuid>
```

Prefer `replace-fact` and `replace-preference` over delete-and-readd for durable memory changes or obsolescence.

## References

Read `references/examples.md` when you need:
- full command examples for each memory layer
- review examples for `fact`, `preference`, and `entity`
- concrete cases for `high`, `medium`, and `low`
- examples of inspect, search, get-context, replace, update, alias, merge, and delete flows
