---
name: python-uv
description: Skill for using uv as Python package manager and interpreter.
---

# uv — Python Package Manager

**Never use bare `python`, `pip`, or activate venvs manually. Always use `uv`.**

## Core commands

```bash
uv run script.py              # run a script
uv run -m pytest              # run a module
uv add requests               # add runtime dependency
uv add --dev pytest           # add dev dependency
uv remove requests            # remove dependency
uv sync                       # sync env to pyproject.toml + uv.lock
uv sync --frozen              # CI: fail if lock is out of date
uv lock --upgrade             # update all dependencies
uv lock --upgrade-package requests  # update one package
uv init myproject             # new project
uv python install 3.12        # install Python version
uv python pin 3.12            # pin version (.python-version)
```

## Non-obvious commands

```bash
# Find available versions of a package on PyPI
uv pip index versions <package>

# Sync without dev deps (production)
uv sync --no-dev

# Run with extra packages (without adding to project)
uv run --with httpx script.py
```

## Migration cheat-sheet

| Old | uv |
|---|---|
| `pip install pkg` | `uv add pkg` |
| `pip install -r requirements.txt` | `uv sync` |
| `python script.py` | `uv run script.py` |
| `poetry add pkg` | `uv add pkg` |
| `poetry install` | `uv sync` |
| `poetry shell` | not needed — use `uv run` |
| `source .venv/bin/activate` | not needed — use `uv run` |

## CI pattern

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
uv sync --frozen   # exact versions from lock
uv run pytest
```

## Key files

- `pyproject.toml` — project metadata + dependencies
- `uv.lock` — locked versions (commit this)
- `.python-version` — pinned Python version (commit this)
- `.venv/` — virtual environment (do NOT commit)
