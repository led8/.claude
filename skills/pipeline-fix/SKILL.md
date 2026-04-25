---
name: pipeline-fix
description: Comprehensive skill for diagnosing and fixing failed CI/CD pipelines in GitLab
---

# Pipeline Fix

Structured workflow for diagnosing and fixing failed GitLab CI/CD pipelines.

## Workflow

### 1. Identify the failed pipeline

```bash
# From MR number
glab api graphql -f query='
query {
  project(fullPath: "owner/repo") {
    mergeRequest(iid: "MR_NUMBER") {
      sourceBranch
      pipelines(first: 1) { nodes { iid status } }
    }
  }
}'

# From current branch
glab pipeline list
```

### 2. Get failed jobs

```bash
glab api graphql -f query='
query {
  project(fullPath: "owner/repo") {
    pipeline(iid: "PIPELINE_IID") {
      jobs { nodes { id name status } }
    }
  }
}' | jq -r '.data.project.pipeline.jobs.nodes[] | select(.status=="FAILED") | "\(.id) \(.name)"'
```

Extract numeric ID from GraphQL result: `gid://gitlab/Ci::Build/160208907` → `160208907`

### 3. Get logs

```bash
glab ci trace JOB_ID
# For large logs:
glab ci trace JOB_ID > job_logs.txt
```

### 4. Diagnose — log pattern reference

| Log pattern | Root cause |
|---|---|
| `Version 'X.Y.Z' for 'pkg' was not found` | APT package version unavailable — update to current version |
| `exit code: 1` / `exit code: 100` | Command failed — look at preceding lines |
| `ERROR: failed to solve` | Dockerfile build step failed |
| `FAILED tests/...` | Unit/integration test failing |
| `error:` in lint step | Code style/quality violation |
| `timeout` / `connection refused` | Transient network issue — retry first |

### 5. Fix and push

```bash
git fetch origin SOURCE_BRANCH && git checkout SOURCE_BRANCH && git pull
# ... make changes ...
git add <files>
git commit -m "fix(scope): description"
git push
```

### 6. Verify

```bash
glab pipeline list   # confirm new pipeline started
glab pipeline status # monitor status
```

If still failing, repeat from step 2 with the new pipeline IID.

---

## Common patterns

### APT package version unavailable

```bash
# Find available version
docker run -it ubuntu:noble apt-cache policy <package-name>
# Update version pin in Dockerfile
```

### Renovate bot MR failing

Renovate updates Python/npm deps but not system packages. Common mismatch: updated library requires a newer system package version not pinned in Dockerfile.

```bash
# Check what Renovate changed
git diff main..SOURCE_BRANCH -- Dockerfile requirements.txt
# Update system package versions in Dockerfile to match
```

### Multiple failing jobs

Fix build/lint jobs first — they often block downstream test and deploy jobs. One fix can resolve several failures.

### Transient failure

```bash
glab pipeline retry PIPELINE_ID
# If same error on retry → not transient, investigate further
```

---

## Integration

- See [glab skill](../glab/SKILL.md) for GraphQL command details
- See [gitlab-ci skill](../gitlab-ci/SKILL.md) if `.gitlab-ci.yml` needs changes
- See [docker skill](../docker/SKILL.md) for Dockerfile fixes
