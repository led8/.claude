# Provider Architecture Notes

Use this file when behavior seems surprising and you need mental models, not just syntax.

## Core Provider Concepts

- Provider configuration resolves credentials, region, and client settings.
- Service packages implement resource/data-source CRUD and read logic.
- Find/wait/status helpers handle asynchronous AWS operations.
- Tagging and diff-suppression logic can influence plan output shape.

## Practical Debug Angles

- If read-after-create fails, suspect eventual consistency and service-specific waiters.
- If plans show persistent diffs, inspect tag merge rules and diff suppression behavior.
- If import behaves unexpectedly, verify resource identity format for that resource type.

## Region Model

From AWS provider v6 onward, many resources/data sources are region-aware via top-level `region`, reducing multi-provider alias complexity for many scenarios.
