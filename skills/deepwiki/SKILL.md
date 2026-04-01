---
name: deepwiki
description: Extract comprehensive documentation from DeepWiki for every repository.
---

# DeepWiki Skill Generator

## Overview

DeepWiki (https://deepwiki.com/) provides AI-generated, navigable documentation for 300+ popular GitHub repositories. This skill enables you to:

1. **Search** for repositories in DeepWiki via API
2. **Fetch** documentation using [mcporter](../mcporter/) skill

## Quick Start

```bash
# User request
"Fetch documentation for FastAPI from deepwiki"
```

```bash
# Workflow
# 1. Search DeepWiki API for FastAPI
curl -s 'https://api.devin.ai/ada/list_public_indexes?search_repo=fastapi'
# 2. Select most appropriate match (by stars, recency, exact name)
# 3. Use mcporter to list available DeepWiki MCP tools
npx mcporter list https://mcp.deepwiki.com/mcp
# 4. Call appropriate MCP tools to fetch documentation
npx mcporter call 'https://mcp.deepwiki.com/mcp.read_wiki_contents(repoName:"tiangolo/fastapi")'
# 5. Provide documentation directly to user
```

## How It Works

### 1. Repository Search

Search the DeepWiki index for repositories:

```bash
# Search for a specific repository
SEARCH_TERM="fastapi"
RESULTS=$(bash -c "curl -s 'https://api.devin.ai/ada/list_public_indexes?search_repo=$SEARCH_TERM'")

# Select most appropriate match
# Priority: highest stars → most recent update → exact name match
BEST_MATCH=$(echo "$RESULTS" | jq -r '.indices | sort_by(-(.stargazers_count // 0), -(.last_modified // "")) | .[0]')
ORG=$(echo "$BEST_MATCH" | jq -r '.repo_name' | cut -d'/' -f1)
REPO=$(echo "$BEST_MATCH" | jq -r '.repo_name' | cut -d'/' -f2)
```

**API Response format:**
```json
{
  "indices": [
    {
      "id": "v1.9.9.5/PUBLIC/{org}/{repo}/{hash}",
      "repo_name": "{org}/{repo}",
      "last_modified": "2025-07-24T12:38:46.745692+00:00",
      "description": "...",
      "stargazers_count": 70369,
      "language": "JavaScript",
      "topics": ["tag1", "tag2"]
    }
  ],
  "needs_reindex": [],
  "pending_repos": []
}
```

**Handling no results:**
If repo not found in DeepWiki, inform user: "Repository not indexed in DeepWiki. Available similar repos: [list top 3 matches or inform unavailable]"

### 2. Discover DeepWiki MCP Tools

Use mcporter to list available tools from the DeepWiki MCP server:

```bash
# List all available DeepWiki MCP tools
npx mcporter list https://mcp.deepwiki.com/mcp
```

This will show available tools for fetching documentation. Use the appropriate tools to retrieve documentation for the selected repository.

**Example tool names might include:*
```bash
/**
 * Get a list of documentation topics for a GitHub repository.
 * Args:
 * repoName: GitHub repository in owner/repo format (e.g. "facebook/react")
 */
function read_wiki_structure(repoName: string): object;

/**
 * View documentation about a GitHub repository.
 * Args:
 * repoName: GitHub repository in owner/repo format (e.g. "facebook/react")
 */
function read_wiki_contents(repoName: string): object;

/**
 * Ask any question about a GitHub repository and get an AI-powered, context-grounded response.
 * Args:
 * repoName: GitHub repository or list of repositories (max 10) in owner/repo format
 * question: The question to ask about the repository
 */
function ask_question(repoName: unknown, question: string): object;

Examples:
  mcporter call 'https://mcp.deepwiki.com/mcp.read_wiki_structure(repoName:, ...)'

3 tools · 1643ms · HTTP https://mcp.deepwiki.com/mcp
```

### 3. Fetch Documentation

Use mcporter to call DeepWiki MCP tools with the repository information:

```bash
# Example: Call MCP tool to fetch documentation
# (Exact tool names and parameters depend on mcporter list output)
npx mcporter call 'https://mcp.deepwiki.com/mcp.<tool-name>(repoName:"{org}/{repo}")'
```

### 4. Skill Generation

Generate skill following skill-creator patterns:

```
generated-skill/
├── SKILL.md (- Required: core workflow = instructions + metadata)
├── references/ (- Optional: detailed documentation, examples, patterns)
│   ├── api.md (complete API reference)
│   ├── patterns.md (common usage patterns)
│   └── advanced.md (advanced features)
└── agents/
    ├── openai.yaml (- Optional: appearance and dependencies)
```

**Section Priority for Skills:**
1. **SKILL.md content** (keep lean, <500 lines):
   - Overview/Introduction
   - Quick Start / Getting Started
   - Core Concepts
   - Common Patterns
   - Configuration Essentials

2. **references/ content** (detailed deep dives):
   - Complete API Reference
   - Advanced Features
   - Architecture Details
   - Examples & Patterns
   - Troubleshooting

**SKILL.md Structure:**
```markdown
---
name: [tool-name]
description: [What it does + when to use]
---

## Troubleshooting

**Q: Repository not found in DeepWiki**
A: Only 300 most popular repos are indexed. Check if repo is in top 300 by stars on GitHub.

**Q: Documentation seems incomplete**
A: DeepWiki docs are AI-generated. Check the original GitHub repo for complete documentation.

**Q: mcporter command fails**
A: Ensure mcporter is installed: `npm install -g mcporter`. Check that the MCP server URL is correct.

## Quick Reference

### Search a Repository
```bash
bash -c "curl -s 'https://api.devin.ai/ada/list_public_indexes?search_repo=fastapi'" | jq '.indices[0]'
```

### List DeepWiki MCP Tools
```bash
npx mcporter list https://mcp.deepwiki.com/mcp
```

### Call DeepWiki MCP Tool
```bash
npx mcporter call 'https://mcp.deepwiki.com/mcp.<tool-name>(repoName:"{org}/{repo}")'
```