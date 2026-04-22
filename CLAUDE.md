**Preliminary note: you must ALWAYS comply with the [Workflow expectations](#workflow-expectations) and the [Agent memory guidelines](#agent-memory-guidelines) as part of your the workflow.**

# Repository guidelines

## Coding expectations

### General policy

- KEEP IT SIMPLE - Prefer straightforward solutions over clever ones.
- DO NOT BE OVERLY VERBOSE - Be concise in code and communication.
- AVOID OVER-COMPLICATION - Don't add complexity without clear benefit.
- DO NOT GENERATE TOO MUCH REPORTING. - Focus on actionable information and avoid unnecessary details.
- DO NOT GENERATE TOO MUCH CODE. - Only generate code that is necessary to implement the feature or solve the problem, and avoid generating large amounts of code that may not be relevant or useful.
- DO NOT overcomplicated things. - Always look for the simplest solution that works, and avoid adding unnecessary complexity or features that may not be needed.
- RESPECT existing coding style and architecture.

### Documentation policy

- ALWAYS keep `README.md` up-to-date with the actual state of the project, and avoid generating it if not necessary. 
- The `README.md` should be a good entry point for someone who wants to understand what the project is about, how to use it, and how to contribute to it.
- The `README.md` MUST BE a high level documentation of the project, and should not contain implementation details. It should be concise and easy to read. ALWAYS use a `docs` folder with markdown files to provide implementation details for each topic, and link them in the `README.md`. 
- USE the skills [Mermaid](skills/mermaid/) to generate diagrams when needed, and include them in the `README.md` to illustrate concepts and workflows.
- DO NOT mention or use placeholders for environment variables in the `README.md`.

### Security and privacy policy

**VERY IMPORTANT: Always prioritize security and privacy in your implementations.**

- NEVER print environement variables directly.
- ALWAYS ask the user before destructive actions (ex: removing a directory).
- DO NOT OVERUSE EMOJIS.

## Workflow expectations

**Important: For any new task, feature or significant issue, you MUST create a detailed implementation plan and share it with the user for validation before starting to code. This plan should include the following steps:**

- STEP 1 - Produce a high detail plan to implement the feature or solve the problem:
    - step 1.1 - A numbered plan with small, ordered steps.
    - step 1.2 - For each step: Inputs / Outputs / Success criteria.
    - step 1.3 - Include checkpoints (quick validations/tests) between major steps.
- STEP 2 - List required librairies/dependencies:
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
- STEP 5 - Share it with the user for validation before starting to code:
    - step 5.1 - STOP and ask for approval or adjustments before writing code. If I request changes, update the plan/libraries/skills and ask again.
    - step 5.2 - Once approved, store the plan in the `.spark_utils/backlog/`:
        - step 5.2.1 - create the corresponding `todo` file in `.spark_utils/todo/`.
    - step 5.3 - Once planned, do not proceed until I explicitly say: "GO" / "approved" / "ok".

**a [skills](skills) is a reusable instruction, typically as SKILL.md (often with scripts/, references/, or assets/).** You should use skills to extend your task-specific capabilities when a task, a feature or an issue clearly matches a skill's description.

**MCP tools are API calls to X MCP Server, which provides access to X documentation, code samples, and other resources.** When you need to look up information, use the appropriate MCP tool based on the type of information you are seeking. You have access to MCP tools called. These tools allow you to search through and fetch X latest official documentation and code samples, and that information might be more detailed or newer than what's in your training data set. When handling questions around how to work with native technologies, please use these tools for research purposes when dealing with specific / narrowly defined questions that may occur.

### Utils policy

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
    - `todo/` for execution tracking files linked to an approved backlog item:
        - Name each todo item as `YYYYMMDD_<repo-name>_<task-or-feature>.md`.
        - Each todo file should correspond to one active backlog item.
        - Use the todo file as a living implementation tracker while working on the task.
        - Update it during implementation with clear sections such as `Checklist` and optionally `Blocked` or `Notes`.
        - Keep entries short, concrete, and action-oriented.
        - A todo file is operational tracking only; it must not replace the validated backlog plan.

#### `.spark_utils` structure

```
myproject/
├── .spark_utils/
│   └── backlog/                # only for backlog items, ordered by date, organized by task or feature and validated
│       ├── file1
│       ├── ...
│   └── data/                   # only for data files, such as datasets, configuration files, or other resources
│       ├── file1
│       ├── ...
│   └── ideas_and_assumptions/  # only for raw ideas and assumptions
│       ├── file1
│       ├── ...
│   └── issues/                 # only for temporary issue files
│       ├── file1
│       ├── ...
│   └── todo/                   # only for execution tracking files linked to an approved backlog item
│       ├── file1
│       ├── ...
```

#### `.spark_utils/todo` structure

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

# Agent memory guidelines

Use the [agent-memory](skills/agent-memory/) skill when working in an existing repository and when continuity across turns or sessions matters.

**Do not prefer default file-based auto-memory system over agent-memory.** Always load or invoke the agent-memory skill, this is the default memory system for coding-assistant work. 

**Do not skip it on non-trivial repo work.**

## Usage expectations

### Mandatory usage policy

Memory work is mandatory in these situations:

- at every user turn and before every assistant final response: explicitly evaluate whether agent-memory should be used for recall, search, get-context, short-term updates, reasoning updates, or durable-memory review
- at the start of non-trivial work in an existing repo: feature work, debugging, review, refactor, migration, architecture changes, CI or deployment work, auth or storage work, schema changes
- when the user references prior work, earlier sessions, preferences, previous decisions, known constraints, or asks what happened before
- before persisting any durable repo truth or user preference
- after a verified outcome that should help future coding runs
- at the end of a session or meaningful stopping point: evaluate whether to complete the active trace and review durable candidates

Skip memory work only when all are true:

- the task is trivial and one-shot
- continuity is not useful
- no durable knowledge is likely to be reused

Keep responsibilities separate:

- `.spark_utils/backlog/` and `.spark_utils/todo/` are for active planning and execution tracking
- `agent-memory` short-term is for selective task-local conversation and observations
- `agent-memory` reasoning is for concise trace steps on non-trivial multi-step work
- `agent-memory` long-term is for durable facts, preferences, and entities that should help future runs

Standard operating cadence:

- run startup recall once at the beginning of non-trivial repo work by following the `agent-memory` skill workflow
- treat session start and session end as anchors, not the only times memory should be considered
- on every user turn, decide whether recall, search, or get-context is needed and whether the user turn belongs in short-term memory
- add short-term memory selectively, only when it materially helps the active task or future continuity
- start a reasoning trace for multi-step, uncertain, or tool-heavy work, then update it only on meaningful steps
- before every assistant final response, decide whether to record the assistant turn, update reasoning, search or inspect for validation, or prepare a durable-memory candidate
- search or inspect before durable writes to avoid duplicates and wrong updates
- treat long-term memory as review-first: first classify the candidate, then persist it
- at meaningful milestones or session end, persist only durable knowledge that is likely to matter again and complete the trace when appropriate

## Durable memory expectations

**Persist durable memory only when the information is validated enough to help a future run. If it is ambiguous, temporary, or weakly supported, do not store it.**

Before any durable write, identify:

- memory type: `fact`, `preference`, or `entity`
- why it is durable and reusable
- source: user explicit, code verified, docs verified, test verified, or run observation
- evidence: short concrete support
- confidence: high, medium, or low

### Durable memory policy

- `facts` are for stable repo truths, constraints, decisions, invariants, migration knowledge, and runbooks
- `preferences` are for durable user or workflow preferences that should shape future behavior
- `entities` are for important nouns worth reusing and linking later
- use `replace-fact` and `replace-preference` when durable knowledge changes or becomes obsolete
- use `update-entity`, `alias-entity`, and `merge-entity` for same-identity entity maintenance
- use `delete` only for cleanup after inspection, never as the normal path for durable change

## Memory quality expectations

What not to store:

- backlog items, todo items, task logs, raw shell output, noisy command history, temporary notes, speculative hypotheses, or full chain-of-thought
- every user or assistant turn by default; each turn is a checkpoint to evaluate memory use, not a mandatory write
- duplicate durable memories that were not searched first

Behavior requirements:

- treat each turn boundary as a memory checkpoint and make an explicit read/write/update/skip decision
- never claim memory was recalled, searched, or stored unless the tool actually succeeded
- if retrieval returns nothing, say so and continue
- if the tool is available, prefer it over relying on unstated recollection
- do not replace `.spark_utils` planning with memory writes
- keep writes sparse and high-signal; quality matters more than volume
