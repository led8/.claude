---
name: gitignore
description: Skill for generating .gitignore files for a project.
---

# GitIgnore Generation Skill

When creating a `.gitignore`, always use the toptal API — never write it manually.

## Generate

```bash
curl 'https://www.toptal.com/developers/gitignore/api/<tech1>,<tech2>,...' > .gitignore
```

Combine: language + IDE + OS in a single request.

```bash
# Example: Python + VS Code + macOS
curl 'https://www.toptal.com/developers/gitignore/api/python,visualstudiocode,macos' > .gitignore
```

## List available templates

```bash
curl -s https://www.toptal.com/developers/gitignore/dropdown/templates.json | jq -r '.[].id'
```
