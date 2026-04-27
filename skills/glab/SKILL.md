---
name: glab
description: Skill for using glab CLI tool to interact with GitLab.
---

# glab CLI - Agent Usage Guide

`glab` is the GitLab CLI. Use it for MRs, issues, pipelines, and direct API calls.

## Authentication

```bash
glab auth status          # check
glab auth login           # interactive
export GITLAB_TOKEN=...   # non-interactive
```

## Core Commands

```bash
glab mr list [--state opened|merged|closed] [--author <u>] [--assignee <u>]
glab mr view <IID>
glab issue list [--state opened] [--assignee <u>]
glab pipeline list
glab ci trace <JOB_ID>        # most reliable way to get job logs
glab api "projects/:id/..."   # direct REST (always returns JSON)
```

## GraphQL (preferred for pipelines and job details)

```bash
glab api graphql -f query='
query {
  project(fullPath: "owner/repo") {
    mergeRequest(iid: "42") {
      pipelines(first: 1) { nodes { iid status } }
    }
  }
}'
```

**Key rules:**
- Use `fullPath: "owner/repo"` — not numeric project IDs
- Use `iid` for MRs and pipelines, not `id`
- Object fields need nested selection: `stage { name }` not `stage`
- GraphQL `id` returns `gid://gitlab/Ci::Build/160208907` — extract the numeric part for `glab ci trace`

## Common Pitfalls

1. **`glab pipeline view <ID>` and `glab ci view <ID>` are unreliable** (404 errors) — use GraphQL instead
2. **These flags do not exist**: `--with-links`, `--merge-request`, `--pipeline-id` — check `glab <cmd> --help`
3. **GID → numeric ID**: to use `glab ci trace`, strip the GID prefix and pass only the number
4. **GraphQL objects need selection**: `stage` alone fails; use `stage { name }`
5. **Project path encoding in REST**: use `%2F` for `/` in URL paths

## Wiki

No `glab wiki` command exists. Use the API or clone the wiki repo.

```bash
# List pages
glab api "projects/owner%2Frepo/wikis"

# Clone wiki (read/commit locally — never push directly)
git clone git@gitlab.com:owner/repo.wiki.git
```

## Error Reference

| Error | Fix |
|---|---|
| "Must be logged in" | `glab auth login` or set `GITLAB_TOKEN` |
| "could not find a remote" | Add `--repo owner/project` flag |
| "404 Not Found" on pipeline | Use GraphQL instead of `glab pipeline view` |
| "Unknown flag" | Check `glab <cmd> --help` — flag likely doesn't exist |
| GraphQL "Field must have selections" | Add `{ name }` or relevant subfields |
