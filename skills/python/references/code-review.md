# Python Code Review

## Severity scheme

Classify findings as:

- **Critical** — must fix before merge: mutable defaults, bare excepts, missing type hints on public API, hardcoded secrets, SQL injection risk, `shell=True` in subprocess
- **Important** — fix soon: function too complex (>20 lines, cyclomatic >10), missing docstrings on public API, `Any` overuse, global state
- **Minor** — nice to fix: style inconsistencies, missed comprehension opportunities, non-descriptive naming

## Output format

```md
## Code Review

### Summary
[1-2 sentences on overall quality]

### Findings

#### Critical
- **Line X**: [issue] — [fix]

#### Important
- **Line X**: [issue] — [fix]

#### Minor
- **Line X**: [issue] — [fix]

### Positive aspects
- [what's done well]

### Next steps
1. Fix critical issues
2. Run: `uv run ruff check src --fix && uv run ty check src`
```

## Line length

120 characters (org standard — overrides PEP8 default of 79).

## Tooling

- `ruff` — linting + formatting (replaces black, flake8, isort)
- `ty` — type checking (replaces mypy)
- `bandit` / `pip-audit` — security (see references/security.md)
