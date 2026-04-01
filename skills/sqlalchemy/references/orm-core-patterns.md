# ORM and Core Patterns

## Declarative Mapping (2.x style)

```python
from sqlalchemy import ForeignKey, String
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship

class Base(DeclarativeBase):
    pass

class User(Base):
    __tablename__ = "user"
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(50))
    addresses: Mapped[list["Address"]] = relationship(back_populates="user")

class Address(Base):
    __tablename__ = "address"
    id: Mapped[int] = mapped_column(primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("user.id"))
    email: Mapped[str]
    user: Mapped[User] = relationship(back_populates="addresses")
```

## Query Style

Prefer:

```python
stmt = select(User).where(User.name == "alice")
rows = session.scalars(stmt).all()
```

Avoid legacy-heavy `session.query(...)` in new code unless maintaining older code paths.

## Loading Strategies

- `selectinload`: default practical eager-loading strategy for many collections.
- `joinedload`: useful for constrained joins or narrow graphs.
- `lazy="raise"` / `raise_on_sql`: good for catching accidental lazy loads in strict contexts.

Example:

```python
from sqlalchemy.orm import selectinload

stmt = select(User).options(selectinload(User.addresses))
users = session.scalars(stmt).all()
```

## Core vs ORM Decision

- Use ORM for domain entities and unit-of-work style writes.
- Use Core for bulk, SQL-centric, or highly tuned statements.
- Mixing is normal: ORM session can execute Core statements when needed.
