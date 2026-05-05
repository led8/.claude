---
name: make-plan
description: Create a detailed implementation plan for a task, a feature or a significant issue. Use when the user asks to plan a task, create a plan, or invokes /make-plan.
---

# Make Plan

For any new task, feature or significant issue, **you MUST create a detailed implementation plan and share it with the user for validation before starting to code.** 

## Implementation plan policy

This plan should include the following steps:

- STEP 1 - Produce a high detail plan to implement the feature or solve the problem:
    - step 1.1 - A numbered plan with small, ordered steps.
    - step 1.2 - For each step: Inputs / Outputs / Success criteria.
    - step 1.3 - Include checkpoints (quick validations/tests) between major steps.
- STEP 2 - List required libraries/dependencies:
    - step 2.1 - Separate: mandatory / optional.
    - step 2.2 - Separate: runtime vs dev/test/tooling.
    - step 2.3 - For each dependency: why it's needed + minimal alternative (if relevant).
- STEP 3 - List skills you will use (if any) to help you with the task:
    - step 3.1 - Provide a bullet list of skills needed for the task
    - step 3.2 - For each skill, tag it as:
        - `[HAVE]` you can handle it and will use it
        - `[MAY NEED]` you might need it and will ask me for docs/examples/spec/access
- STEP 4 - List available MCP tools you will use (if any) to help you with the task:
    - step 4.1 - Provide a bullet list of MCP tools needed for the task
    - step 4.2 - For each MCP tool, tag it as:
        - `[HAVE]` you can handle it and will use it
        - `[MAY NEED]` you might need it and will ask me for docs/examples/spec/access
- STEP 5 - Share it with the user for validation **BEFORE starting to code:**
    - step 5.1 - STOP and ask for approval or adjustments **BEFORE writing code**. If I request changes, update the plan/libraries/skills and ask again.
    - step 5.2 - Once approved, store the plan in the `.spark_utils/backlog/`:
        - step 5.2.1 - create the corresponding `todo` file in `.spark_utils/todo/`.
    - step 5.3 - **Once planned, do not proceed until I explicitly say: "GO" / "approved" / "ok".**
- STEP 6 - Once the task is done, update the `.spark_utils/sessions_resume/` using [make-session-resume](../make-session-resume/SKILL.md) skill.

**A skill is a reusable instruction, usually defined in `SKILL.md`** (and sometimes supported by `scripts/`, `references/`, or `assets/`).

- Use a skill when the task clearly matches its purpose.
- When a skill applies, read it and follow it.
- The skills are in the `skills/` folder, at the [root](../).

**MCP tools provide direct access to external documentation, code samples, and other live resources.**

- Use the appropriate MCP tool when you need precise or up-to-date information.
- Prefer MCP tools for targeted research on specific technologies or APIs.
- Treat MCP results as the primary source when they are available.
- MCP tools are accessed via the `mcporter` CLI (see [mcporter](../mcporter/SKILL.md) skill):
  - Always run `mcporter list` first to confirm server availability before using a tool.
  - Call syntax: `mcporter call <server>.<tool> key=value` or `--args '{"key":"value"}'`
  - Use `mcporter list <server> --schema` to inspect available tools and their parameters before calling.
  - Prefer `--output json` for machine-readable results that can be piped or saved.
  - If a server is `offline`, do not retry more than once — flag it to the user instead.
  - Never infer tool names or parameters from memory: always check the schema first.

### Implementation plan storage policy

- ALWAYS create a `.spark_utils` (if it doesn't exist) folder at the root of the project for utility files.
- Inside `.spark_utils`, create separate folders for different types of files:
    - `backlog/` for backlog items, ordered by date, organized by task or feature and validated:
        - Name each backlog item as `YYYYMMDD_<repo-name>_<task-or-feature>.md`.
        - Each backlog item must reflect the workflow (steps 1, 2, 3 and 4).
        - Each backlog item must be created only after validation by the user.
        - Each backlog item should be a markdown file.
        - A backlog file is the validated implementation plan and must remain the reference for the feature or task.
    - `data/` for any data files needed for the project, such as datasets, configuration files, or other resources.
    - `ideas_and_assumptions/` for raw ideas and assumptions. This is a free space for brainstorming and capturing thoughts, and should not be considered as actionable items until they are moved to the backlog after validation.
    - `issues/` for temporary issue files.
    - `sessions_resume/` for session summaries or handoff notes from the current conversation and work context.
    - `todo/` for execution tracking files linked to an approved backlog item:
        - Name each todo item as `YYYYMMDD_<repo-name>_<task-or-feature>.md`.
        - Each todo file should correspond to one active backlog item.
        - Use the todo file as a living implementation tracker while working on the task.
        - Update it during implementation with clear sections such as `Checklist` and optionally `Blocked` or `Notes`.
        - Keep entries short, concrete, and action-oriented.
        - A todo file is operational tracking only; it must not replace the validated backlog plan.

#### `.spark_utils/` tree structure

```
myproject/
├── .spark_utils/
│   └── backlog/
│       ├── file
│   └── data/
│       ├── file
│   └── ideas_and_assumptions/
│       ├── file
│   └── issues/
│       ├── file
│   └── sessions_resume/
│       ├── file
│   └── todo/
│       ├── file
```

#### `.spark_utils/todo/` file guidelines

Each `todo` file should use a single implementation checklist like:

```md
# Task: <task-or-feature-name>

## Checklist
- [x] implement API route
- [ ] add validation
- [ ] update service layer
- [ ] add tests
- [ ] run final verification

## Blocked
- [ ] waiting for clarification on auth flow

## Notes
- short useful note
- short useful note
```

Guidelines:
- use [ ] for not done items
- use [x] for completed items
- keep items small, concrete, and action-oriented
- update the checklist continuously while implementing
- keep Blocked only for real blockers
- do not use the todo file as a backlog replacement or as a detailed report
