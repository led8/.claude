---
name: agent-memory
description: Portable wrapper and workflow for Neo4j Agent Memory in task-scoped coding sessions.
---

# Agent Memory

Use this skill for non-trivial coding work when task continuity or durable repo knowledge matters.

## Read First

- [scripts/agent-memory.sh](scripts/agent-memory.sh)
- [references/examples.md](references/examples.md)

## What This Skill Adds

This skill is not a generic memory tutorial. It adds a portable local workflow for Codex:

- one wrapper command that finds `neo4j-agent-memory`
- automatic `.env` loading when the tool repo provides one
- automatic `--local-embedder` injection for `memory ...` commands
- a simple cadence: startup, milestone, finish
- clear behavior when Neo4j is blocked by the sandbox

## Wrapper First

Prefer the wrapper instead of hardcoded machine paths:

```bash
skills/agent-memory/scripts/agent-memory.sh doctor
```

The wrapper tries, in order:

1. `AGENT_MEMORY_BIN`
2. `AGENT_MEMORY_HOME/.venv/bin/neo4j-agent-memory`
3. `neo4j-agent-memory` on `PATH`
4. common repo locations under `~/code`, `~/src`, and `~/projects`

If a tool home is found, the wrapper loads its `.env` file automatically.
If the command starts with `memory`, the wrapper adds `--local-embedder`
unless you already passed `--local-embedder` or `--hashed-local-embedder`.

## Core Rules

1. Use one `session_id` per active coding task.
2. Use `short-term` selectively for task continuity, not raw shell logs.
3. Open `reasoning` traces only for multi-step or uncertain work.
4. Treat long-term memory as review-first.
5. Search or inspect before durable writes.
6. Use `replace-fact` and `replace-preference` when durable entries change.
7. Use `update-entity`, `alias-entity`, and `merge-entity` for same-identity entity maintenance.
8. Never inline literal secrets in commands or examples.

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

### 1. Startup

Run this once for the active task:

```bash
skills/agent-memory/scripts/agent-memory.sh memory session-id --repo <repo> --task "<task>"
skills/agent-memory/scripts/agent-memory.sh memory recall --repo <repo> --task "<task>" --session-id "<session-id>"
```

Use startup recall as the anchor for non-trivial repo work.

### 2. Milestone

During the task, choose the smallest useful action:

- `search` for one fact, preference, entity, or message thread
- `get-context` for a compact combined view
- `add-message` only when the turn materially helps continuity
- `start-trace` and `complete-trace` only for multi-step work

### 3. Finish

At a meaningful stopping point:

- update reasoning if the trace gained a useful result
- review durable memory candidates
- persist only validated durable knowledge

## Availability And Sandbox Policy

If the wrapper cannot find the binary, `.env`, or a working CLI path, report the failure once for the active task and keep that unavailable state sticky until something changes.

If the CLI works but Neo4j access fails with a localhost permission error from Codex, treat that as a sandbox issue. Retry with an escalated command instead of declaring the backend unavailable.

If the backend stays unavailable after a real retry, continue the task without memory and mention the known unavailable state only when it changes or when the final response needs that context.

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

## Related Reference

- Use [references/examples.md](references/examples.md) for short runnable command patterns.
