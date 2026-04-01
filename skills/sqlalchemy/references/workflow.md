# Workflow

## Standard SQLAlchemy 2.x Flow

1. Build engine once for process lifetime.
2. Define models with `DeclarativeBase`, `Mapped`, `mapped_column`.
3. Use short-lived sessions via context managers.
4. Wrap writes in explicit transaction blocks.
5. Use `select()` for reads and explicit loader options for relationships.

## Sync Baseline

```python
from sqlalchemy import create_engine, select
from sqlalchemy.orm import Session

engine = create_engine("postgresql+psycopg://user:pass@host/db")

with Session(engine) as session:
    with session.begin():
        session.add(User(name="alice"))

    users = session.scalars(select(User)).all()
```

## Core Transaction Pattern

```python
from sqlalchemy import text

with engine.connect() as conn:
    with conn.begin():
        conn.execute(text("insert into audit_log(event) values ('ok')"))
```

## Migration Touchpoint

- Keep models authoritative for schema intent.
- Use Alembic for migration generation and application.
- Do not rely on ad-hoc runtime `create_all()` in mature production systems.
