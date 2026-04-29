# Refactor Review Checklist

Use this checklist after the initial repo scan and before choosing the implementation slices.

## 1. Architecture And Boundaries

Check for:

- modules that mix orchestration, business logic, persistence, and formatting
- routes, controllers, commands, or UI components that own too much logic
- helpers that became informal service layers
- cross-layer imports that bypass intended boundaries
- circular or nearly circular dependencies
- shared modules that act as dumping grounds

Questions:

- What are the natural seams of the codebase?
- Which modules already behave like services but are not isolated?
- Which dependencies should point inward but currently point sideways?

## 2. Dead Code And Stale Paths

Check for:

- unused exports
- unused files
- obsolete feature flags
- duplicated fallback paths that are no longer exercised
- wrappers that only forward calls without adding value
- compatibility code for removed behavior

Evidence sources:

- global search
- import/reference checks
- test coverage or runtime references when available
- build and type errors after targeted removal

## 3. Duplication

Check for:

- repeated validation logic
- repeated mapping or serialization logic
- repeated API or DB access patterns
- similar condition trees spread across modules
- near-identical utility helpers with different names

Good consolidation targets:

- code with the same responsibility and the same lifecycle
- code that can be hidden behind a small explicit API

Bad consolidation targets:

- superficially similar code with different domain intent
- code that would require a generic abstraction harder to understand than duplication

## 4. Module Shape

Look for:

- files that are too large to reason about comfortably
- modules with multiple unrelated exports
- directories where names do not match responsibility
- "utils" modules that hide domain logic
- internal APIs that are wider than consumers need

Typical improvements:

- split one large file by responsibility
- create a narrow service module
- move domain helpers closer to their owning feature
- reduce re-export noise

## 5. Naming

Check for:

- vague names like `helper`, `manager`, `common`, `misc`, `data`, `process`
- names that describe implementation instead of responsibility
- inconsistent naming between layers
- old names that no longer match current behavior

Rename only when it improves understanding enough to justify the churn.

## 6. Side Effects And IO

Check for:

- hidden network, filesystem, database, or environment access in shared helpers
- modules that both compute and perform side effects
- tightly coupled code that makes testing difficult
- retry, caching, or logging behavior duplicated across call sites

Prefer to isolate side effects behind explicit modules or adapters.

## 7. Tests And Verification

Check for:

- missing coverage around code you plan to move or delete
- brittle tests coupled to implementation details
- absent smoke tests for critical entrypoints
- no validation path for high-risk modules

If verification is weak:

- shrink scope
- add small targeted tests only where they materially de-risk the refactor

## 8. Prioritization

Prioritize refactor slices with this order:

1. high confidence dead code removal
2. duplication reduction with low contract risk
3. extraction of clear responsibilities from oversized modules
4. boundary cleanup between existing layers
5. risky structural changes that need stronger validation

Skip or defer work when:

- payoff is mostly aesthetic
- the change mixes refactor and product behavior
- validation is too weak for the risk
- the right boundary is still unclear
