# Auth & Low-level Server

## OAuth 2.1 — Server as Resource Server

MCP servers act as **Resource Servers** (RS) that validate Bearer tokens issued by a separate Authorization Server (AS). Implements RFC 9728 Protected Resource Metadata for AS discovery.

```python
from pydantic import AnyHttpUrl
from mcp.server.auth.provider import AccessToken, TokenVerifier
from mcp.server.auth.settings import AuthSettings
from mcp.server.fastmcp import FastMCP

class MyTokenVerifier(TokenVerifier):
    """Validate tokens against your AS (JWT, introspection, etc.)."""

    async def verify_token(self, token: str) -> AccessToken | None:
        # Return AccessToken on success, None to reject
        payload = decode_jwt(token)  # your JWT library
        if not payload or payload.get("exp", 0) < time.time():
            return None
        return AccessToken(
            token=token,
            client_id=payload["sub"],
            scopes=payload.get("scope", "").split(),
        )

mcp = FastMCP(
    "Protected Service",
    json_response=True,
    token_verifier=MyTokenVerifier(),
    auth=AuthSettings(
        issuer_url=AnyHttpUrl("https://auth.example.com"),        # AS URL
        resource_server_url=AnyHttpUrl("http://localhost:8000"),   # this server
        required_scopes=["read"],
    ),
)

@mcp.tool()
def protected_data() -> str:
    """Only accessible with valid token."""
    return "secret"

if __name__ == "__main__":
    mcp.run(transport="streamable-http")
```

### Architecture

```
Client ──(OAuth flow)──► Authorization Server (AS)
                              │ issues token
Client ──(Bearer token)──► MCP Server / Resource Server (RS)
                              │ verify_token()
                              └─ serves tools/resources
```

### Auth Pitfalls

- `verify_token` returning `None` for valid tokens → all requests rejected.
- Not checking token expiry (`exp` claim) → expired tokens accepted.
- `InMemoryTokenStorage` in production (client side) → tokens lost on restart.
- Missing `resource_server_url` in `AuthSettings` → RFC 9728 AS discovery fails.
- Forgetting HTTPS in production → tokens intercepted in transit.

---

## Low-level Server API

Use `mcp.server.lowlevel.Server` when you need control FastMCP doesn't provide:
dynamic tool registration at runtime, custom protocol handling, pagination, or fine-grained capability declarations.

> `mcp dev` and `mcp run` **do not** support the low-level Server — use `python server.py` directly.

### Basic skeleton

```python
import asyncio
import mcp.server.stdio
import mcp.types as types
from mcp.server.lowlevel import NotificationOptions, Server
from mcp.server.models import InitializationOptions

server = Server("my-server")

@server.list_tools()
async def list_tools() -> list[types.Tool]:
    return [
        types.Tool(
            name="echo",
            description="Echo input",
            inputSchema={
                "type": "object",
                "properties": {"text": {"type": "string"}},
                "required": ["text"],
            },
        )
    ]

@server.call_tool()
async def call_tool(name: str, arguments: dict) -> list[types.TextContent]:
    if name != "echo":
        raise ValueError(f"Unknown tool: {name}")
    return [types.TextContent(type="text", text=arguments["text"])]

async def run():
    async with mcp.server.stdio.stdio_server() as (r, w):
        await server.run(
            r, w,
            InitializationOptions(
                server_name="my-server",
                server_version="1.0.0",
                capabilities=server.get_capabilities(
                    notification_options=NotificationOptions(),
                    experimental_capabilities={},
                ),
            ),
        )

if __name__ == "__main__":
    asyncio.run(run())
```

### With Lifespan

```python
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager
from typing import Any

@asynccontextmanager
async def lifespan(_server: Server) -> AsyncIterator[dict[str, Any]]:
    db = {"connected": True}  # replace with real resource init
    try:
        yield {"db": db}
    finally:
        db["connected"] = False

server = Server("my-server", lifespan=lifespan)

@server.call_tool()
async def call_tool(name: str, arguments: dict) -> list[types.TextContent]:
    ctx = server.request_context            # access lifespan context here
    db  = ctx.lifespan_context["db"]
    return [types.TextContent(type="text", text=f"db={db}, args={arguments}")]
```

### Structured output (low-level)

Return a `dict` from `call_tool` and define `outputSchema` on the `Tool`:

```python
@server.list_tools()
async def list_tools() -> list[types.Tool]:
    return [types.Tool(
        name="stats",
        description="Get stats",
        inputSchema={"type": "object", "properties": {}, "required": []},
        outputSchema={
            "type": "object",
            "properties": {"mean": {"type": "number"}, "count": {"type": "integer"}},
            "required": ["mean", "count"],
        },
    )]

@server.call_tool()
async def call_tool(name: str, arguments: dict) -> dict:
    return {"mean": 42.5, "count": 100}   # validated against outputSchema
```

### Return types for `call_tool`

| Return | Behaviour |
|--------|-----------|
| `list[TextContent\|ImageContent\|...]` | Unstructured — backward compatible |
| `dict` | Structured — must match `outputSchema` if defined |
| `tuple(content, dict)` | Both (recommended for compatibility) |
| `CallToolResult` | Full manual control + `_meta` field |

### Claude Desktop config (manual — mcp install not available)

```json
{
  "mcpServers": {
    "my-lowlevel-server": {
      "command": "python",
      "args": ["/abs/path/to/server.py"]
    }
  }
}
```

### Pagination

```python
@server.list_resources()
async def list_resources(request: types.ListResourcesRequest) -> types.ListResourcesResult:
    page_size = 10
    cursor = request.params.cursor if request.params else None
    start = 0 if cursor is None else int(cursor)
    items = ALL_RESOURCES[start:start + page_size]
    next_cursor = str(start + page_size) if start + page_size < len(ALL_RESOURCES) else None
    return types.ListResourcesResult(resources=items, nextCursor=next_cursor)
```

### Low-level Pitfalls

- **Always `raise ValueError`** for unknown tool names in `call_tool` — silent failures are hard to debug.
- **`server.request_context` is only valid inside a handler** — accessing it elsewhere raises `AttributeError`.
- **No input validation by default** — manually validate all `arguments`.
- Define `outputSchema` on the `Tool` when returning a `dict` — without it, structured content won't be validated.
