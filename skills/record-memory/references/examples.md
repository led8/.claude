# Agent Memory Examples

Use these examples when the skill summary is not enough.

All examples use the portable wrapper:

```bash
agent-memory ...
```

The wrapper auto-loads the tool repo `.env` when it can find it and injects `--local-embedder` for `memory ...` commands.

## 1. Doctor (preflight, once per session)

Always run this before the first `memory ...` call in a session:

```bash
agent-memory doctor
```

Parse the output to decide whether memory is available. See the `Step 0` and `Availability And Sandbox Policy` sections of `SKILL.md` for how to act on each field. If the preflight fails, do not loop on `memory ...` commands.

## 2. Startup

Create a task-scoped session id:

```bash
agent-memory memory session-id \
  --repo claude \
  --task "audit embedded skills"
```

Then run startup recall:

```bash
agent-memory memory recall \
  --repo claude \
  --task "audit embedded skills" \
  --session-id "coding/claude/audit-embedded-skills/run-1"
```

## 3. Mid-Task Retrieval

Use `search` when you want one layer:

```bash
agent-memory memory search \
  --kind fact \
  --query "docker proxy build args"
```

Use `get-context` when you want a compact combined view:

```bash
agent-memory memory get-context \
  --query "current task constraints for docker skill audit" \
  --session-id "coding/claude/audit-embedded-skills/run-1" \
  --include-short-term \
  --include-long-term \
  --include-reasoning \
  --max-items 6
```

## 4. Short-Term Memory

Store only task-useful turns:

```bash
agent-memory memory add-message \
  --session-id "coding/<repo>/<task-slug>/run-1" \
  --role user \
  --no-extract-entities \
  --no-extract-relations \
  "User confirmed the target constraint for this task."
```

Delete a short-term message only by UUID after inspection:

```bash
agent-memory memory delete-message --id <message-uuid>
```

## 5. Reasoning

Open a trace only for multi-step work:

```bash
agent-memory memory start-trace \
  --session-id "coding/claude/audit-embedded-skills/run-1" \
  --task "audit embedded skills"
```

Add a step:

```bash
agent-memory memory add-trace-step \
  --trace-id <trace-uuid> \
  --thought "Check whether the skill adds non-obvious instructions." \
  --action "Read the skill and compare it with agent defaults."
```

Complete the trace at a milestone or task end:

```bash
agent-memory memory complete-trace \
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
agent-memory memory add-fact \
  --repo claude \
  --task "audit embedded skills" \
  --subject "docker skill" \
  --predicate "positioning" \
  --object-value "must remain a policy skill rather than a generic Docker tutorial"
```

## 7. Provenance Inspection

Check evidence before overwriting:

```bash
agent-memory memory get-provenance fact <fact-uuid>
```

Output includes the traces and messages that supported the fact.

## 8. Persistent Candidate Review

List candidates stored in the graph:

```bash
agent-memory memory list-candidates --status proposed
agent-memory memory list-candidates --status proposed --type fact
```

Accept or ignore after review:

```bash
agent-memory memory accept-candidate <candidate-uuid>
agent-memory memory ignore-candidate <candidate-uuid>
```

Inspect a single candidate:

```bash
agent-memory memory get-candidate <candidate-uuid>
```

## 9. Recall With Provenance

Get richer recall output annotated with evidence sources:

```bash
agent-memory memory recall \
  --repo claude \
  --task "audit embedded skills" \
  --session-id "coding/claude/audit-embedded-skills/run-1" \
  --include-provenance
```

Each fact and preference in the output will include `[trace:...]` or `[msg:...]` annotations showing where the knowledge came from.