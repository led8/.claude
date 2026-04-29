---
name: make-refacto
description: Review an entire repository and drive a high-value refactor. Use when the user wants repo-wide cleanup, dead code removal, better module or service boundaries, reduced duplication, improved naming, or safer architecture simplification without changing intended behavior.
---

# Make Refacto

Use this skill for broad refactor work that touches architecture, module boundaries, service isolation, duplication, dead code, or general codebase cleanup.

This is not a "rewrite everything" skill. The goal is a stronger structure with lower risk:

- keep behavior stable unless the user explicitly asks for behavior changes
- remove unnecessary code only when evidence is strong
- prefer small, verifiable slices over a giant rewrite
- improve boundaries, ownership, naming, and testability

## When To Use

Use this skill when the user asks for things like:

- "review the whole repo"
- "make a big refactor"
- "clean this codebase"
- "remove dead or unnecessary code"
- "split responsibilities properly"
- "isolate services, modules, or layers"
- "simplify architecture without changing behavior"

Do not use this skill for:

- a small localized cleanup in one file
- pure feature delivery with no structural problem
- speculative rewrites with no clear pain points

## Core Workflow

### 1. Audit First

Before editing:

1. Map the repo shape.
2. Identify entrypoints, core modules, service boundaries, and shared utilities.
3. Find tests, linters, type checks, and build commands.
4. Look for duplication, dead code, oversized modules, circular dependencies, leaky abstractions, and misplaced responsibilities.
5. Separate findings into:
   - safe cleanup
   - structural refactor
   - risky or behavior-changing work

For repo-wide refactors, create and share a concrete implementation plan before code changes. If `$make-plan` is available, use it.

### 2. Define The Refactor Shape

Choose the smallest change set that produces a meaningful improvement. Prefer:

- extracting coherent services or helpers from large files
- moving code to the layer that actually owns the responsibility
- deleting unused code paths, wrappers, and stale helpers
- consolidating duplicated logic behind one clear API
- renaming unclear modules or functions when it reduces cognitive load
- tightening interfaces between modules

Avoid:

- mixing feature work into refactor work
- changing public contracts without a strong reason
- sweeping renames with weak payoff
- large moves without verification checkpoints

### 3. Execute In Slices

Break the work into slices that can be validated independently. A good slice usually does one of these:

- remove verified dead code
- extract one responsibility
- simplify one dependency chain
- normalize one repeated pattern
- split one oversized module into clear submodules

After each slice:

1. run the smallest relevant validation
2. confirm imports, call sites, and contracts still line up
3. check whether the next slice is still worth doing

### 4. Verify And Document

After the refactor:

- run relevant tests, linters, or builds when available
- state what was verified and what was not
- update high-level docs only if the actual project structure or usage changed

## Refactor Standards

Apply these standards during execution:

- one responsibility per module whenever practical
- one clear owner for side effects, IO, and external integrations
- keep domain logic out of controllers, routes, and UI glue
- keep adapters thin and explicit
- prefer deletion over abstraction when code is unused
- prefer explicit dependencies over hidden cross-module reach
- preserve existing style unless there is a clear repo-wide pattern to improve
- do not add frameworks, layers, or patterns without a concrete payoff

## Safety Rules

- Do not remove code unless usage checks, tests, or call-site inspection support it.
- Do not claim behavior preservation without verification.
- Do not silently change external APIs, storage formats, or CLI contracts.
- Treat generated files, migrations, and configuration wiring as high-risk areas.
- If a broad refactor would be hard to validate, reduce scope and ship the highest-value safe cleanup first.

## Review Checklist

Read [references/refactor-review-checklist.md](references/refactor-review-checklist.md) when you need a fuller audit checklist or a way to prioritize findings.

Use it to inspect:

- architecture and boundaries
- dead code and stale abstractions
- duplication and utility sprawl
- testability and verification gaps
- naming and module ownership

## Output Expectations

When using this skill, the response should usually contain:

1. a short audit summary
2. the proposed refactor slices in priority order
3. the code changes made
4. the verification performed
5. any remaining risks or deferred cleanup

If the user asks for "the best refactor" without constraints, bias toward the highest-value safe refactor, not the largest possible diff.
