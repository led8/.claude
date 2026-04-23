---
name: docker
description: Docker repo policy skill for local build rules, proxy args, SSL handling, and validation.
---

# Docker

Use this skill for Docker or Docker Compose work when local policy matters. Do not use it as a generic Docker tutorial. Rely on model knowledge for standard commands, common Dockerfile patterns, and routine Compose syntax.

## Read First

- [Core Rules](references/core-rules.md)

## What This Skill Adds

This skill exists for repo-local and environment-specific constraints:

- where Dockerfiles and Compose files should live
- which build entrypoints must work
- how proxy settings must be passed
- when a corporate SSL certificate is required
- which validation steps are expected before finishing

If the task is just "write a normal Dockerfile" or "explain `docker compose up`", do not load extra references beyond `core-rules.md` unless a local constraint forces it.

## Workflow

1. Read [references/core-rules.md](references/core-rules.md) before editing Docker assets.
2. Inspect the repo for existing `Dockerfile*`, `docker-compose*.yml`, `.dockerignore`, and CI expectations.
3. Make the smallest change that satisfies the task and respects local policy.
4. Keep generic Docker design decisions context-sensitive:
   - prefer multi-stage builds when they reduce runtime size or isolate build tooling
   - prefer non-root users for long-running app containers
   - avoid hardcoding secrets into images
5. Apply local proxy and certificate rules only when the environment or repo requires them.
6. Validate the result with the checks from `core-rules.md`.

## Guardrails

- Do not hardcode credentials, tokens, or private URLs into images unless the repo already treats them as public constants.
- Do not suggest destructive cleanup commands such as `docker system prune -a` unless the user explicitly asks for cleanup.
- Do not force Alpine, distroless, or rootless images when the workload or dependencies make that choice unsafe.
- Do not add proxy environment variables to runtime `environment:` blocks when the local policy requires build args instead.
- Do not add a corporate certificate step unless the repo or environment actually depends on internal TLS interception.

## Validation

Default validation sequence:

1. Lint Dockerfiles with `hadolint` when available.
2. Validate Compose files with `docker compose config` when Compose is part of the change.
3. Run the relevant build command required by local policy.
4. If the task involves runnable services, verify the container starts cleanly or explain why that verification was not run.

## Related Skills

- For Python image builds, also read [../python/SKILL.md](../python/SKILL.md) when the task depends on `uv`, packaging, or Python runtime layout.
