---
name: mermaid
description: Comprehensive skill for generating diagrams using Mermaid syntax.
---

# Mermaid Diagrams

Before generating any diagram, read the appropriate reference file:

| Use case | Reference |
|---|---|
| API calls, interactions, process flows | [references/sequence-diagram.md](references/sequence-diagram.md) |
| Class structure, OO design | [references/class-diagram.md](references/class-diagram.md) |
| Database schema, entity relationships | [references/er-diagram.md](references/er-diagram.md) |
| State machines, workflow states | [references/state-diagram.md](references/state-diagram.md) |
| Project timelines, task scheduling | [references/gantt.md](references/gantt.md) |
| Git branching, release flows | [references/gitgraph.md](references/gitgraph.md) |

## Generating image files with mmdc

```bash
# PNG — always use -s 10 (without it, output is blurry)
mmdc -i diagram.mmd -o diagram.png -s 10 -b transparent

# SVG
mmdc -i diagram.mmd -o diagram.svg

# Batch
for f in *.mmd; do mmdc -i "$f" -o "${f%.mmd}.png" -s 10 -b transparent; done
```
