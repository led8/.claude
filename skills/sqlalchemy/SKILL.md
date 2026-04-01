---
name: sqlalchemy
description: Build, review, and troubleshoot SQLAlchemy 2.x code for ORM and Core usage. Use for engine/session setup, mappings, query patterns, async usage, and performance-safe loading strategies.
---

# SQLAlchemy

Use this skill for SQLAlchemy code design, fixes, reviews, and debugging (sync or async).

## Quick Start

```python
from sqlalchemy import create_engine, select
from sqlalchemy.orm import DeclarativeBase, Mapped, Session, mapped_column

engine = create_engine("sqlite:///app.db")

class Base(DeclarativeBase):
    pass

class User(Base):
    __tablename__ = "user"
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str]

Base.metadata.create_all(engine)

with Session(engine) as session:
    with session.begin():
        session.add(User(name="alice"))
    users = session.scalars(select(User)).all()
```

## Workflow Routing

- Day-to-day development flow: `references/workflow.md`
- Core vs ORM patterns and loading strategy: `references/orm-core-patterns.md`
- Async engine/session and pooling: `references/async-and-pooling.md`
- Failure modes and debugging checklist: `references/troubleshooting.md`

## Core Rules

1. Prefer SQLAlchemy 2.x style (`select()` + `Session.execute()` / `Session.scalars()`).
2. Scope sessions to a request/job/unit-of-work, not global process state.
3. Make transaction boundaries explicit (`session.begin()` or `connection.begin()`).
4. Prevent N+1 problems with explicit loader strategies (`selectinload`, `joinedload`).
5. Use async APIs consistently; do not mix sync DB calls in async request paths.
6. Tune connection pool settings intentionally for workload and DB limits.

## Common Patterns

### Transaction-safe write block

```python
with Session(engine) as session:
    with session.begin():
        session.add(obj)
        session.add(other_obj)
```

### Relationship eager loading

```python
from sqlalchemy import select
from sqlalchemy.orm import selectinload

stmt = select(User).options(selectinload(User.addresses))
rows = session.scalars(stmt).all()
```

### Async baseline

```python
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker

engine = create_async_engine("postgresql+asyncpg://user:pass@host/db")
AsyncSessionLocal = async_sessionmaker(engine, expire_on_commit=False)
```

## Documentation Sources

- DeepWiki architecture and subsystem map: `sqlalchemy/sqlalchemy`

Use `alembic` for schema migrations; SQLAlchemy provides metadata/mapping, not migration orchestration.
