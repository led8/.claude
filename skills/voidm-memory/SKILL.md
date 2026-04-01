---
name: voidm-memory
description: Use local cli-based persistent memory and trajectory-informed learning tips with voidm for coding and repository work.
---

# Voidm Memory

## Purpose

Use `voidm` as the local long-term memory for repository work.

This skill exists to make memory useful, sparse, and durable. Use it to recall prior knowledge before acting, and to preserve only the parts of current work that will still matter later.

## Core Operating Rules

1. Use the local `voidm` CLI only.
2. Always search before adding memory or learning tips.
3. Scope repository memory by repo name only.
4. Store durable knowledge only.
5. Never store raw task logs, session summaries, or temporary execution notes.
6. Rewrite events into reusable knowledge before storing them.
7. Prefer fewer, higher-quality memories over many shallow ones.
8. Use `voidm learn` for generalized tactics distilled from trajectories.
9. Preview ingestion and consolidation before any `--write`.
10. Treat repo scope as the first search ring, not a hard wall.

## Two Storage Lanes

Use regular memory for repo knowledge:
  •	architecture
  •	constraints
  •	decisions
  •	procedures
  •	user preferences

Use `voidm learn` for structured learning tips when the value is a reusable tactic with explicit provenance:
  •	strategy
  •	recovery
  •	optimization

Rule of thumb:
  •	if the knowledge explains how this repo works, use `voidm add`
  •	if the knowledge is a reusable tactic learned from a run, use `voidm learn`

These lanes complement each other. Do not replace architectural memory or user preferences with learning tips.

## Repo Scope Policy

Derive the scope from the repository root name and use that exact repo name as `--scope`.

Example:

```bash
voidm search "auth" --scope my-repo
voidm add "Constraint: auth requests fail closed when Redis session validation is unavailable." --type semantic --scope my-repo
```

Do not create subscopes such as branch names, ticket numbers, dates, temporary feature names, or user-specific subpaths.

Stay at repo scope unless the user explicitly changes the policy.

This rule is for storage. Search is broader:
  •	start repo-scoped when the task is clearly repo-specific
  •	drop `--scope` when results are thin or the answer may live outside the repo
  •	use `--intent` and graph-aware retrieval to widen recall before assuming memory does not exist

## Startup Recall Protocol

At the beginning of any non-trivial task in a repo, run a structured recall pass before planning or coding.

Always search at least these five categories when relevant:
  1.	architecture
  2.	constraints
  3.	decisions
  4.	procedures
  5.	user preferences

Recommended pattern:

```bash
voidm search "architecture" --scope my-repo
voidm search "constraints" --scope my-repo
voidm search "decisions" --scope my-repo
voidm search "procedures" --scope my-repo
voidm search "user preferences" --scope my-repo
```

Then run 1 to 3 task-specific searches:

```bash
voidm search "hydration" --scope my-repo
voidm search "deployment order" --scope my-repo
voidm search "redis auth sessions" --scope my-repo --json
```

If the repo-scoped pass is sparse, generic, or obviously too local, widen the search:

```bash
voidm search "redis auth sessions"
voidm search "auth" --intent "oauth2" --include-neighbors --json
```

## When Recall Is Mandatory

Run recall before acting when:
  •	entering an existing repository
  •	planning a feature or refactor
  •	debugging a recurring or non-trivial issue
  •	changing architecture or dependencies
  •	touching authentication, storage, caching, migrations, deployment, CI, build, or integrations
  •	the user asks for continuity, history, prior decisions, known pitfalls, or stable preferences

For trivial edits or isolated wording changes, compact recall is acceptable.

## Search In Widening Rings

Use the repo as the first ring, not the search cage.

Recommended order:
  1.	repo-scoped recall for local architecture, constraints, procedures, and preferences
  2.	unscoped search when you need reusable patterns, tool behavior, or cross-repo memory
  3.	`--intent` when the query is ambiguous but you know the technical context
  4.	`--include-neighbors` when links, tags, or ontology edges are likely to matter

Good signals to widen:
  •	few or no scoped results
  •	results are near-matches but miss the real concept
  •	the question is about a tool, protocol, library, or generic debugging pattern
  •	the repo may not be the only relevant scope

## When To Use `voidm learn`

Use `voidm learn` when a reusable tactic can be stated with:
  •	a trigger
  •	an application context
  •	a task category
  •	a source outcome
  •	one or more source trajectory ids

Use `voidm learn add` when you already know the tip and its metadata.

Use `voidm learn ingest --from <file> --dry-run` when you have structured coding-agent trajectories and want `voidm` to extract candidate tips first.

Use `voidm learn search` when you want only learning tips back, not general repo memory.

Use `voidm learn get <id>` when you need to inspect one stored tip before reusing, linking, or consolidating it.

Use `voidm learn consolidate` when overlapping active learning tips are accumulating and canonical records would reduce noise.

Do not use `voidm learn` for:
  •	repo architecture
  •	stable constraints
  •	user workflow preferences
  •	current plans or execution logs

Current boundary:
  •	ingest works from explicit trajectory files only
  •	no automatic runtime or stream ingestion

## Memory Eligibility Test

Only add memory if the information passes this test.

Add memory only when the information is:
  •	durable
  •	reusable
  •	non-trivial
  •	specific enough to help later
  •	likely to matter again in this repo

Before adding, ask:
  •	will this still help in two weeks?
  •	does this capture a constraint, decision, procedure, architecture, preference, or reusable lesson?
  •	is this better than leaving it in the temporary plan only?
  •	did I search first and confirm it is not already covered?

If the answer is weak, do not store it.

## What Must Never Enter Memory

Do not store:
  •	task logs
  •	session summaries
  •	“I fixed X today”
  •	temporary checklists
  •	current sprint items
  •	branch-specific implementation notes
  •	raw command output
  •	raw trajectory dumps
  •	one-off debugging traces
  •	unvalidated speculation
  •	wording copied verbatim from a temporary backlog when it has no durable value

Bad examples:

```bash
voidm add "Fixed settings bug today" --type semantic --scope my-repo
voidm add "Need to implement profile form next" --type semantic --scope my-repo
voidm add "Ran tests and they passed" --type semantic --scope my-repo
```

These are execution history, not reusable memory.

## What Should Enter Memory

Good candidates:
  •	architectural relationships
  •	stable constraints and invariants
  •	design decisions and rationale
  •	reusable debugging patterns
  •	runbooks and deployment or migration procedures
  •	integration knowledge specific to the repo
  •	durable user workflow preferences
  •	lessons that generalize beyond one incident
  •	trajectory-informed strategy, recovery, or optimization tips

Good examples:

```bash
voidm add "Architecture: settings components depend on fully initialized UserContext; partial initialization causes rendering failures in settings-related views." --type conceptual --scope my-repo
voidm add "Procedure: for hydration bugs, verify SSR/client markup parity first, then inspect early window access, then validate UserContext initialization." --type procedural --scope my-repo
voidm add "Decision: keep TypeScript as the primary implementation language in this repo because build tooling, review habits, and existing modules are TypeScript-first." --type semantic --scope my-repo
```

## Memory Type Policy

Choose the type deliberately.

### Semantic

Use for:
  •	constraints
  •	decisions
  •	stable facts
  •	user preferences
  •	system characteristics
  •	repo-specific knowledge that is descriptive rather than step-by-step

### Procedural

Use for:
  •	runbooks
  •	debugging workflows
  •	migration order
  •	deployment sequences
  •	repeatable operational patterns

### Conceptual

Use for:
  •	architecture
  •	component relationships
  •	system boundaries
  •	subsystem mental models
  •	dependency structure

### Fallback Rule

If the local installation exposes different or additional types, use the closest supported type without blocking. Do not skip memory just because the ideal type name differs.

## Rewrite Rule: Essence Over History

Never store the event itself when the durable lesson can be extracted.

Rewrite this:

```text
Fixed Docker build bug today.
```

Into this:

```text
Procedure: when the base image or system dependency layer changes, force a clean rebuild to avoid stale cache layers producing misleading local success.
```

Rewrite this:

```text
Implemented dashboard and had auth context issues.
```

Into this:

```text
Constraint: dashboard rendering assumes auth context is initialized before data hooks execute; partial auth initialization produces cascading fetch and render failures.
```

Rewrite this:

```text
Had to ask for approval before coding.
```

Into this:

```text
Preference: for non-trivial coding tasks, provide a detailed plan and wait for explicit approval before editing files.
```

## Standard Memory Writing Pattern

Prefer this structure:
  •	Label
  •	Core statement
  •	Why it matters
  •	When it applies

Use short but information-dense wording.

Examples:

```text
Constraint: migrations must complete before worker rollout. Why it matters: workers assume the new column exists immediately. When it applies: any deploy that changes schema used by async jobs.
```

```text
Procedure: debug hydration issues by checking markup parity, early browser API usage, and context initialization order. Why it matters: these are the three highest-frequency causes in this repo. When it applies: SSR or client hydration mismatches.
```

```text
Decision: keep Redis-backed session validation in the auth path. Why it matters: current security model depends on centralized session invalidation. When it applies: auth and session architecture changes.
```

## Search-Before-Add Protocol

Before any add, follow this workflow:
  1.	Identify the candidate memory.
  2.	Search once with a narrow query.
  3.	Search once with a broader conceptual query.
  4.	Inspect whether the candidate is already captured.
  5.	If the knowledge already exists, do not add a duplicate.
  6.	If the new knowledge extends an existing memory, prefer linking instead of restating.
  7.	Add only if the knowledge is meaningfully distinct.

Recommended pattern:

```bash
voidm search "hydration bug" --scope my-repo
voidm search "context initialization rendering" --scope my-repo --json
```

When the second scoped query is still weak, widen instead of repeating the same local search:

```bash
voidm search "context initialization rendering"
voidm search "auth" --intent "oauth2" --include-neighbors --json
```

For learning tips, use the same rule with `voidm learn search` before `voidm learn add`:

```bash
voidm learn search "oauth refresh" --scope my-repo --category recovery --task-category authentication
```

## Duplicate Handling

When search results overlap strongly with the candidate memory:
  •	do not restate the same point with different wording
  •	prefer not adding anything
  •	or add only the new distinct part
  •	create a link when the relationship is useful

Use `voidm` add warnings and suggested links when available.

Default bias: avoid duplication.

## Linking Policy

Create links only when they improve future retrieval.

Bias toward more deliberate links than you think you need. If two memories are useful together in reasoning, they usually deserve a graph edge.

Preferred relations:
  •	SUPPORTS
  •	DERIVED_FROM
  •	PART_OF

Use `RELATES_TO` only with a meaningful note.

Important:
  •	auto-linking from shared tags helps, but it mostly creates generic `RELATES_TO`
  •	explicit links are still needed for stronger semantics such as `SUPPORTS`, `DERIVED_FROM`, and `PART_OF`
  •	prefer `--link` during `voidm add` when the relationship is already obvious
  •	use `voidm link` immediately after insertion when a useful relationship becomes clear during review

Examples:

```bash
voidm add "Procedure: deploy schema changes before worker rollout." --type procedural --scope my-repo --link <constraint-id>:SUPPORTS
voidm link <decision-id> SUPPORTS <constraint-id>
voidm link <runbook-id> DERIVED_FROM <incident-pattern-id>
voidm link <auth-cache-id> PART_OF <auth-architecture-id>
voidm link <id1> RELATES_TO <id2> --note "both affect deployment ordering"
```

Do not create decorative links.

## Tags And Ontology

Tags are cheap. Concepts are durable.

Use `--tags` more often than you do now when you already know stable labels that matter for retrieval:
  •	subsystem names
  •	protocols
  •	libraries
  •	product names
  •	recurring incident labels

Auto-tags are useful but imperfect. Add manual tags when the label is obvious and important.

Examples:

```bash
voidm add "Procedure: retry OAuth refresh with jittered backoff before failing the CLI login flow." --type procedural --scope my-repo --tags "oauth2,jwt,auth,cli"
```

Promote repeated nouns into ontology concepts when they become reusable classes rather than one-off keywords.

Good ontology triggers:
  •	the same component or domain concept appears across multiple memories
  •	you want subtype or instance reasoning
  •	graph retrieval would benefit from concept hierarchies, not just tag overlap

Examples:

```bash
voidm ontology concept add "AuthService" --description "Handles JWT + OAuth2 flows" --scope my-repo
voidm ontology link <memory-id> --from-kind memory INSTANCE_OF <concept-id> --to-kind concept
voidm ontology enrich-memories --scope my-repo --dry-run
```

Do not force ontology for every noun. Use it for recurring classes, components, and architectural concepts.

## Contradictions And Staleness

When new evidence conflicts with existing memory:
  1.	search the existing memory first
  2.	do not silently pile up contradictory duplicates
  3.	prefer a clearer updated memory over ambiguous parallel statements
  4.	link or resolve contradictions only when the conflict is real and durable
	5.	treat old operational details as stale unless reconfirmed

If a memory is obsolete, favor replacement of understanding over accumulation of noise.

## User Preference Capture Policy

The user’s workflow preferences are durable memory and should be preserved once per repo when relevant.

Capture a preference only when evidence is strong:
  •	the user states it explicitly
  •	or the same behavior repeats across multiple tasks
  •	or the user corrects a prior approach and gives a stable alternative

Store repo-relevant collaboration preferences only.
Do not build personality profiles, personal dossiers, or speculative behavior labels.

Important standing preferences include:
  •	for non-trivial tasks, produce a detailed plan before coding
  •	include ordered steps, inputs, outputs, and success criteria
  •	include validation checkpoints between major phases
  •	identify required dependencies and separate mandatory vs optional and runtime vs dev/test/tooling when relevant
  •	stop and ask for approval before writing or editing files on non-trivial tasks
  •	prefer structured, persistent project context over ad hoc execution
  •	stay local-first and cli-first

Do not copy the full workflow verbatim into memory unless necessary. Compress it into a reusable preference.
Keep preference memory concise and operational.

When a preference changes:
  1.	search for the existing preference memory first
  2.	write a clearer updated preference
  3.	link old and new only if the relation helps future retrieval
  4.	treat stale preference memory as obsolete and avoid reusing it

Good example:

```bash
voidm add "Preference: for non-trivial tasks in this repo, produce a detailed numbered plan with validation checkpoints and wait for explicit approval before editing files." --type semantic --scope my-repo
```

```bash
voidm add "Preference: default to concise, findings-first responses with numbered next steps only when actionable." --type semantic --scope my-repo
```

Bad example:

```bash
voidm add "STEP 1 produce a highly detailed plan, STEP 2 list dependencies, STEP 3 list skills..." --type semantic --scope my-repo
```

```bash
voidm add "User behavior profile: curious, skeptical, strict, likes deep analysis and long reports..." --type contextual --scope user
```

## Plan Versus Memory

Keep this distinction strict.

### Plan

Used to execute the current task.

Examples:
  •	feature checklist
  •	current implementation steps
  •	immediate validation checklist
  •	files to edit now

### Memory

Used to improve future sessions.

Examples:
  •	a stable architectural dependency
  •	a repeated failure mode
  •	a durable debugging method
  •	a long-term user preference
  •	a design decision and rationale

**A plan can generate memory later, but a plan itself is not memory.**

## Extraction Moments

At the end of meaningful work, pause and ask what should survive.

Typical moments for extraction:
  •	after resolving a hard bug
  •	after choosing between approaches
  •	after discovering a new repo constraint
  •	after stabilizing a workflow
  •	after clarifying a recurring user preference
  •	after understanding a subsystem more clearly

Then extract only the durable lesson.

## Command Recipes

### Recall

```bash
voidm search "architecture" --scope my-repo
voidm search "constraints" --scope my-repo
voidm search "procedure" --scope my-repo
voidm search "user preference" --scope my-repo
voidm search "specific topic" --scope my-repo --json
```

```bash
voidm search "specific topic"
voidm search "auth" --intent "oauth2" --include-neighbors --json
```

### Add

```bash
voidm add "Constraint: auth requests fail closed when Redis session validation is unavailable. Why it matters: degraded Redis causes auth latency and authorization instability. When it applies: auth-path changes and incident response." --type semantic --scope my-repo
```

```bash
voidm add "Procedure: deploy schema changes before worker rollout. Why it matters: workers assume the new schema immediately. When it applies: migrations that alter async job payloads or read paths." --type procedural --scope my-repo
```

```bash
voidm add "Architecture: the read path flows through API cache, then read replicas, then primary fallback. Why it matters: debugging latency requires checking each layer in this order. When it applies: performance and cache correctness issues." --type conceptual --scope my-repo
```

```bash
voidm add "Procedure: retry OAuth refresh with jittered backoff before failing the CLI login flow. Why it matters: transient 401s are recoverable. When it applies: token refresh failures in auth flows." --type procedural --scope my-repo --tags "oauth2,jwt,auth,cli" --link <auth-constraint-id>:SUPPORTS
```

### Learn

```bash
voidm learn add "Inspect the existing code path before editing when debugging a repo-specific failure." \
  --category strategy \
  --trigger "non-trivial bug fix in existing code" \
  --application-context "existing repository debugging" \
  --task-category debugging \
  --source-outcome success \
  --trajectory traj-debug-20260320-01 \
  --scope my-repo
```

```bash
voidm learn ingest --from trajectory.json --dry-run --json
voidm learn ingest --from trajectory.json --write --scope my-repo --json
```

```bash
voidm learn search "token refresh" --category recovery --task-category authentication --scope my-repo --json
voidm learn get <id> --json
voidm learn consolidate --scope my-repo --dry-run --json
```

### Link

```bash
voidm link <procedure-id> DERIVED_FROM <incident-id>
voidm link <decision-id> SUPPORTS <constraint-id>
voidm link <subsystem-id> PART_OF <architecture-id>
```

### Ontology

```bash
voidm ontology concept add "AuthService" --description "Handles JWT + OAuth2 flows" --scope my-repo
voidm ontology link <memory-id> --from-kind memory INSTANCE_OF <concept-id> --to-kind concept
voidm ontology enrich-memories --scope my-repo --dry-run
```

## Decision Heuristic

Before adding memory, ask:
  •	is this durable?
  •	is this reusable?
  •	is this specific enough to be useful?
  •	is this better than leaving it only in the temporary plan?
  •	have I already searched for it?

Only add when the answer is convincingly yes.

## Default Behavior Summary

When this skill triggers:
  1.	determine repo name
  2.	run startup recall in repo scope
  3.	if scoped recall is weak or the task is cross-cutting, widen beyond repo scope
  4.	proceed with planning and execution using recalled context
  5.	choose the right storage lane: `voidm add` or `voidm learn`
  6.	during work, notice candidate durable lessons
  7.	search before adding any memory or learning tip
  8.	add manual tags when stable labels are obvious
  9.	bias toward explicit links, not just auto-linking
  10.	promote recurring classes to ontology concepts when it improves retrieval
  11.	if trajectories exist, prefer `voidm learn ingest --dry-run` before manual learning-tip writes
  12.	write compact high-value entries only
  13.	avoid duplicates, logs, and temporary plans
  14.	link or consolidate only when that improves future retrieval

## Additional Examples

For more examples of good and bad memory candidates, see [Memory Examples](references/memory-examples.md).
