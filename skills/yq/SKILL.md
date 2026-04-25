---
name: yq
description: Comprehensive skill for parsing and manipulating YAML using yq
---

# yq — YAML Processing

**Always use `mikefarah/yq` v4+ (Go), not the Python wrapper.**

Detect which version is installed:
```bash
yq --version
# Go:     yq (https://github.com/mikefarah/yq/) version v4.x.x
# Python: yq 3.x.x  ← wrong one
```

If you see `Error: Pipe is not a valid function` — you have the Python wrapper.

## Non-obvious features

### `env()` — read environment variables in expressions

```bash
yq -i '.database.password = env(DB_PASSWORD)' config.yaml
yq '.host = env(HOST) | .port = env(PORT)' config.yaml
```

### `fileIndex` — multi-file merge

```bash
# file2 overrides file1
yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' base.yaml override.yaml
```

### Comments are preserved

Unlike Python PyYAML and most parsers, yq preserves comments on in-place edits.

### Field names with special characters

```bash
yq '.["api.key"]' config.yaml
yq '.["first name"]' config.yaml
```

## Quick reference

```bash
yq -r '.field' file.yaml                          # raw string (no YAML quotes)
yq -i '.field = "value"' file.yaml               # in-place edit
yq -e '.field' file.yaml                          # exit 1 if null/missing
yq '.field // "default"' file.yaml               # default value
yq '.items[] | select(.active == true)' file.yaml # filter array
yq -o json '.' file.yaml                          # YAML → JSON
yq -P '.' file.json                               # JSON → YAML
yq -i '.array += ["item"]' file.yaml              # append to array
```
