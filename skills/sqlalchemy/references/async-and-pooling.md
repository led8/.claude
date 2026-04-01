# Async and Pooling

## Async ORM Baseline

```python
from sqlalchemy import select
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker

engine = create_async_engine(
    "postgresql+asyncpg://user:pass@host/db",
    echo=False,
)
AsyncSessionLocal = async_sessionmaker(engine, expire_on_commit=False)

async with AsyncSessionLocal() as session:
    result = await session.scalars(select(User))
    users = result.all()
```

## Async DDL / Sync Bridge

```python
async with engine.begin() as conn:
    await conn.run_sync(Base.metadata.create_all)
```

`run_sync()` is the safe bridge for sync helpers under async engine/connection control.

## Pool Configuration

```python
from sqlalchemy import create_engine

engine = create_engine(
    "mysql+mysqldb://u:p@host/db",
    pool_size=10,
    max_overflow=20,
)
```

Tune pool settings based on DB connection budget and request concurrency.

## Debug Flags

```python
engine = create_engine("sqlite://", echo=True, echo_pool="debug")
```

- `echo=True`: logs SQL statements.
- `echo_pool="debug"`: logs pool checkouts/checkins/resets.

Use in development or incident debugging, not as default production verbosity.
