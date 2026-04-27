---
name: make-session-resume
description: Create a concise session summary or handoff note from the current conversation and work context. Use when the user asks for a session summary, session resume, handoff, checkpoint, recap, or a record of what was built, fixed, decided, verified, and learned about user or coding preferences.
---

# Make Session Resume

Use this skill to produce a clean summary of the current session without inventing work that did not happen.

## When To Use

Use this skill when the user asks for any of the following:

- a session summary
- a session resume
- a checkpoint or recap
- a handoff note for later work
- a summary of what was built, fixed, investigated, or decided
- a summary of user preferences or coding preferences observed during the session

## Source Of Truth

Build the summary from:

- the current conversation
- actual code changes made in the session
- commands or tests that actually ran
- explicit user statements

Do not infer completed work from intentions alone.
Do not claim a bug was fixed, a test passed, or a decision was made unless it happened in the session.

## What To Capture

Capture only the items that are materially useful for continuing the work later.

### 1. Session Goal

State the user request or active objective in one or two sentences.

### 2. Work Completed

List concrete work that was actually done:

- features implemented
- bugs fixed
- files or areas changed
- docs updated
- tooling or workflow updates

### 3. Work Investigated

Include important analysis that did not end in a code change when it affects future work:

- root cause found
- options considered
- constraints discovered
- blockers identified

### 4. Decisions

Record decisions that shape later work:

- architecture choices
- naming choices
- scope boundaries
- deferred items

### 5. Verification

Record only real verification:

- tests run
- builds run
- manual checks performed
- things not verified yet

### 6. Preferences

Split preferences into two groups when relevant:

- user preferences
- coding or implementation preferences

Only include preferences that were explicit, repeated, or clearly acted on. Avoid one-off guesses.

### 7. Open Items

Capture what remains unresolved:

- unfinished work
- known risks
- missing validation
- next recommended step

## Output Rules

Keep the summary concise, factual, and easy to scan.

- Prefer short sections over long prose.
- Use past tense for completed work.
- Mark unknown or unverified items clearly.
- Separate `done`, `investigated`, and `next` items.
- Omit trivia, filler, and raw shell logs.
- Never include secrets, tokens, or environment variable values.

## Storage Requirement

After preparing the session resume, store it on disk.

- Ensure the folder `.spark_utils/sessions_resume/` exists at the repo root.
- Write the summary to `.spark_utils/sessions_resume/YYYYMMDD_<repo_name>.md`.
- Use the current date for `YYYYMMDD`.
- Use the repository directory name for `<repo_name>`.
- If the file already exists for that day and repo, update it instead of creating a duplicate.

## Default Output Format

Use this format unless the user asks for another shape:

### Session Goal

[1-2 sentence summary]

### Completed

- [completed item]

### Investigated

- [important investigation item]

### Decisions

- [decision]

### Preferences

- User: [preference]
- Coding: [preference]

### Verification

- [test, build, or manual check]

### Open Items

- [remaining issue or risk]

### Next Step

[single best next action]

Omit empty sections instead of filling them with placeholders.

## Handoff Variant

If the user asks for a handoff note, bias toward continuity for the next agent or next session. Include:

- current objective
- latest completed work
- exact unresolved issue
- most relevant files or components
- next recommended action

## Compression Rule

If the session was short, produce a very short summary.
If the session was long, compress aggressively and keep only durable, task-relevant information.
