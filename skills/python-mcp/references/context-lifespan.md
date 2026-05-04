# Context & Lifespan

## Lifespan Pattern

Use `lifespan` to initialize shared resources (DB connections, HTTP clients, config) once at startup and tear them down cleanly on shutdown. Never initialize these inside tool functions.

```python
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager
from dataclasses import dataclass
from mcp.server.fastmcp import FastMCP, Context
from mcp.server.session import ServerSession

class Database:
    @classmethod
    async def connect(cls): return cls()
    async def disconnect(self): pass
    def query(self, q: str) -> str: return f"result:{q}"

@dataclass
class AppContext:
    db: Database

@asynccontextmanager
async def app_lifespan(server: FastMCP) -> AsyncIterator[AppContext]:
    db = await Database.connect()
    try:
        yield AppContext(db=db)
    finally:
        await db.disconnect()

mcp = FastMCP("My App", lifespan=app_lifespan)

@mcp.tool()
def run_query(query: str, ctx: Context[ServerSession, AppContext]) -> str:
    """Run a DB query."""
    db = ctx.request_context.lifespan_context.db
    return db.query(query)
```

## Context API

The `ctx` parameter is auto-injected — any name works as long as it's annotated with `Context`.

```python
# Full Context[SessionType, LifespanContextType] for IDE autocomplete
ctx: Context[ServerSession, AppContext]
# Simplified (fine for quick usage)
ctx: Context
```

### Logging

```python
await ctx.debug("Verbose trace message")
await ctx.info("Key milestone")
await ctx.warning("Something unexpected but recoverable")
await ctx.error("Something failed")
await ctx.log("info", "Custom logger", logger_name="my.module")
```

> Log messages are MCP protocol notifications sent to the client — do **not** log passwords, tokens, or PII.

### Progress Reporting

```python
await ctx.report_progress(
    progress=0.5,      # current value
    total=1.0,         # total (None = unknown)
    message="Step 2/4 done",
)
```

Progress only displays if the client sends a `progressToken` — Claude Desktop/Code does this automatically.

### Resource Reading

```python
contents = await ctx.read_resource("config://settings")
text = contents[0].text
```

### Other Properties

```python
ctx.request_id        # unique ID for this request
ctx.client_id         # client ID if available
ctx.session           # raw ServerSession (for advanced session methods)
ctx.fastmcp           # FastMCP server instance
ctx.request_context.lifespan_context   # typed lifespan state
ctx.request_context.meta               # progressToken, etc.
ctx.request_context.request            # original MCP request
```

## Session Notification Methods

Use these to push change notifications to clients:

```python
await ctx.session.send_resource_list_changed()         # resource list changed
await ctx.session.send_resource_updated(AnyUrl(uri))   # specific resource changed
await ctx.session.send_tool_list_changed()             # tool list changed
await ctx.session.send_prompt_list_changed()           # prompt list changed
```

> List-change notifications require a **stateful** session — they are not delivered in `stateless_http=True` mode.

## Pitfalls

- `ctx.request_context.lifespan_context` is `None` when no `lifespan=` was passed.
- Tools using `await ctx.*` must be `async def`.
- Lifespan context is **shared** across all requests — never store per-request user data in it.
- The `finally` block in lifespan **must** run cleanup — an unhandled exception before `yield` leaves resources leaked.
