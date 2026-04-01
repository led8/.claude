# Troubleshooting

## High-Impact Failure Modes

## Session scope

Do:
- Keep sessions short-lived and scoped to request/job/unit-of-work.
- Close sessions deterministically via context managers.

Do not:
- Reuse one mutable global `Session` across concurrent operations.
- Issue SQL from sessions in invalid terminal states.

## N+1 and loader issues

Do:
- Add `selectinload`/`joinedload` to relationship-heavy queries.
- Use strict lazy strategies (for example `lazy="raise"`) where accidental SQL is costly.

Do not:
- Iterate objects and access lazy relationships blindly in loops.

## Transaction boundaries

Do:
- Use explicit `session.begin()` / `conn.begin()` blocks.
- Make rollback behavior deterministic on exceptions.

Do not:
- Depend on implicit transactional behavior across frameworks and threads.

## Pool pressure and connection churn

Do:
- Size `pool_size` / `max_overflow` according to real traffic.
- Inspect pool logs with `echo_pool="debug"` during incidents.

Do not:
- Treat timeout or pool exhaustion errors as query bugs before checking pool limits.

## Async pitfalls

Do:
- Use async engine/session APIs consistently in async paths.
- Use eager loading options to avoid implicit lazy-load surprises.

Do not:
- Mix blocking sync DB calls directly inside asyncio request handlers.

## Quick Diagnostic Checklist

1. Enable temporary SQL/pool logging (`echo`, `echo_pool`).
2. Verify session and transaction scope boundaries.
3. Check query count for N+1 symptoms.
4. Check pool utilization and timeout metrics.
5. Reproduce with minimal query and explicit loader options.
