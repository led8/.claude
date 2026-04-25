---
name: python
description: Comprehensive skill for Python development with modern tooling.
---

# Python Development

## Reference files

Read the appropriate reference before writing code:

| Topic | Reference |
|---|---|
| Project structure, paradigm, stack | [references/core-rules.md](references/core-rules.md) |
| Logging | [references/logging.md](references/logging.md) |
| Testing | [references/testing.md](references/testing.md) |
| HTTP client (httpx + hishel + tenacity) | [references/httpx.md](references/httpx.md) |
| Tool config (pyproject.toml) | [references/project-config.md](references/project-config.md) |
| Secrets & settings | [references/secrets.md](references/secrets.md) |
| Docker setup | [references/docker.md](references/docker.md) |
| Code examples (FastAPI, Click, Sentry) | [references/examples.md](references/examples.md) |
| Code review | [references/code-review.md](references/code-review.md) |
| Security (bandit, pip-audit, semgrep) | [references/security.md](references/security.md) |

## Non-obvious rules

- **Always use `uv`**: `uv run python script.py`, never `python3 script.py`
- **PYTHONPATH**: `PYTHONPATH=src/ uv run ...` when needed
- **120 chars/line** (not PEP8 default of 79)
- **Lazy logging**: `logger.info("msg %s", var)` — never f-strings in log calls
- **CLI**: use `click`, not `typer`
- **Stack**: `fastapi` + `uvicorn`, `orjson` > `json`, `hishel`/`httpx`, `pydantic_settings`

## Quality toolchain

```bash
# Format
uv run black src tests

# Lint (+ autofix)
uv run ruff check src tests --fix

# Type check
uv run ty check src

# Tests + coverage
uv run pytest --cov=src --cov-report=term

# All-in-one (before commit)
uv run black src tests && uv run ruff check src tests --fix && uv run ty check src && uv run pytest
```
