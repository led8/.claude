# Agent Memory Examples

Use these examples when the skill summary is not enough.

All examples use the portable wrapper:

```bash
skills/agent-memory/scripts/agent-memory.sh ...
```

The wrapper auto-loads the tool repo `.env` when it can find it and injects
`--local-embedder` for `memory ...` commands.

## 1. Doctor

Check whether the local setup is discoverable before you conclude memory is unavailable:

```bash
skills/agent-memory/scripts/agent-memory.sh doctor
```

## 2. Startup

Create a task-scoped session id:

```bash
skills/agent-memory/scripts/agent-memory.sh memory session-id \
  --repo codex \
  --task "audit embedded skills"
```

Then run startup recall:

```bash
skills/agent-memory/scripts/agent-memory.sh memory recall \
  --repo codex \
  --task "audit embedded skills" \
  --session-id "coding/codex/audit-embedded-skills/run-1"
```

If Neo4j access fails with `Operation not permitted`, retry the same command with an escalated shell execution from Codex.

## 3. Mid-Task Retrieval

Use `search` when you want one layer:

```bash
skills/agent-memory/scripts/agent-memory.sh memory search \
  --kind fact \
  --query "docker proxy build args"
```

Use `get-context` when you want a compact combined view:

```bash
skills/agent-memory/scripts/agent-memory.sh memory get-context \
  --query "current task constraints for docker skill audit" \
  --session-id "coding/codex/audit-embedded-skills/run-1" \
  --include-short-term \
  --include-long-term \
  --include-reasoning \
  --max-items 3
```

## 4. Short-Term Memory

Store only task-useful turns:

```bash
skills/agent-memory/scripts/agent-memory.sh memory add-message \
  --session-id "coding/codex/audit-embedded-skills/run-1" \
  --role user \
  --no-extract-entities \
  --no-extract-relations \
  "User wants an audit of embedded Codex skills."
```

Delete a short-term message only by UUID after inspection:

```bash
skills/agent-memory/scripts/agent-memory.sh memory delete-message --id <message-uuid>
```

## 5. Reasoning

Open a trace only for multi-step work:

```bash
skills/agent-memory/scripts/agent-memory.sh memory start-trace \
  --session-id "coding/codex/audit-embedded-skills/run-1" \
  --task "audit embedded skills"
```

Add a step:

```bash
skills/agent-memory/scripts/agent-memory.sh memory add-trace-step \
  --trace-id <trace-uuid> \
  --thought "Check whether the skill adds non-obvious instructions." \
  --action "Read the skill and compare it with agent defaults."
```

Complete the trace at a milestone or task end:

```bash
skills/agent-memory/scripts/agent-memory.sh memory complete-trace \
  --trace-id <trace-uuid> \
  --outcome "Reduced generic skills and kept only policy-heavy ones." \
  --success
```

## 6. Durable Review And Write

Use the review block before any durable write:

```text
[Long-term candidate]
type: fact
scope: repo
content: The docker skill should stay policy-focused and avoid generic tutorials.
why: Stable design rule for future skill reviews.
source: code_verified
confidence: high
evidence: Verified by auditing the skill content and simplifying it in the repo.
suggested_action: remember_fact
decision_needed: persist | ignore
```

If the candidate is approved and durable, write it:

```bash
skills/agent-memory/scripts/agent-memory.sh memory add-fact \
  --repo codex \
  --task "audit embedded skills" \
  --subject "docker skill" \
  --predicate "positioning" \
  --object-value "must remain a policy skill rather than a generic Docker tutorial"
```
