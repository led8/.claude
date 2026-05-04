---
name: python-mcp
description: >
  Build MCP (Model Context Protocol) servers and clients using the official Python SDK (package: mcp / mcp[cli]).
  Use this skill whenever the user mentions MCP, FastMCP, modelcontextprotocol, MCP tools, MCP resources,
  MCP prompts, Claude Desktop integration via MCP, building a local tool server for Claude, or anything involving
  the mcp Python package. Also triggers for phrases like "expose a function to Claude", "create a tool for
  Claude Code", "connect to an MCP server from Python", or "register server in Claude Desktop".
  Covers: FastMCP server, tools/resources/prompts, transports (stdio, Streamable HTTP, SSE), MCP client,
  context & lifespan, structured output, elicitation, sampling, auth/OAuth, image content,
  notifications & progress, MCP CLI, and the low-level Server API.
---

# Python MCP SDK

**Package:** `mcp` / `mcp[cli]` | **Python:** ≥3.10 | **Latest stable:** v1.27.0

> v1.x is the current stable branch. The `main` branch is v2 pre-alpha — do not use in production.

## Installation

```bash
# Recommended
uv add "mcp[cli]"      # [cli] adds mcp dev / mcp run / mcp install

# pip alternative
pip install "mcp[cli]"
```

---

## FastMCP Server

```python
from mcp.server.fastmcp import FastMCP, Context, Image
from mcp.server.session import ServerSession

mcp = FastMCP(
    "My Server",
    instructions="Optional description shown to clients",
    stateless_http=True,   # for HTTP: no session affinity needed
    json_response=True,    # for HTTP: JSON instead of SSE streaming
    lifespan=app_lifespan, # optional: startup/shutdown hook
    debug=False,
)

if __name__ == "__main__":
    mcp.run()                             # stdio (default)
    # mcp.run(transport="streamable-http")  # HTTP on :8000/mcp
    # mcp.run(transport="sse")              # legacy SSE
```

For the lifespan / shared resources pattern → see `references/context-lifespan.md`.

---

## Tools

```python
from pydantic import BaseModel, Field

# Simple sync tool
@mcp.tool()
def add(a: int, b: int) -> int:
    """Add two numbers."""  # docstring = tool description
    return a + b

# Async tool with Context (logging + progress)
@mcp.tool()
async def process(data: str, ctx: Context[ServerSession, None], steps: int = 3) -> str:
    """Process data with progress updates."""
    for i in range(steps):
        await ctx.report_progress(progress=(i+1)/steps, total=1.0, message=f"Step {i+1}")
        await ctx.info(f"Step {i+1} done")
    return f"Processed: {data}"

# Structured output via Pydantic (auto-generates outputSchema)
class WeatherData(BaseModel):
    temperature: float = Field(description="Celsius")
    condition: str

@mcp.tool()
def get_weather(city: str) -> WeatherData:
    """Get weather."""
    return WeatherData(temperature=22.5, condition="sunny")

# Disable structured output
@mcp.tool(structured_output=False)
def raw_tool(x: int) -> dict:
    return {"result": x}
```

**Structured output types:** `BaseModel` · `TypedDict` · `dataclass` (with annotations) · `dict[str, T]` · primitives (auto-wrapped `{"result": value}`)

**Client-side consumption:**
```python
result = await session.call_tool("get_weather", {"city": "Paris"})
result.content[0].text        # unstructured (always present, backward-compat)
result.structuredContent      # dict — only when server returns structured type
result.isError                # True if the tool raised an exception
```

---

## Resources

```python
# Static resource
@mcp.resource("config://settings", mime_type="application/json")
def get_settings() -> str:
    return '{"theme": "dark"}'

# Dynamic resource template — {param} maps to function argument
@mcp.resource("file://documents/{name}")
def read_doc(name: str) -> str:
    return f"Content of {name}"

# Binary resource
@mcp.resource("image://logo", mime_type="image/png")
def get_logo() -> bytes:
    return open("logo.png", "rb").read()
```

**Client-side:**
```python
resources = await session.list_resources()
result    = await session.read_resource(AnyUrl("config://settings"))
text      = result.contents[0].text
```

Resources are **read-only** (like GET). For side-effecting operations, use tools.
Validate URI template params to prevent path traversal.

---

## Prompts

```python
from mcp.server.fastmcp.prompts import base

# Single-turn (return str → converted to UserMessage)
@mcp.prompt(title="Code Review")
def review_code(code: str) -> str:
    return f"Please review this code:\n\n{code}"

# Multi-turn conversation starter
@mcp.prompt()
def debug_error(error: str, language: str = "Python") -> list[base.Message]:
    return [
        base.UserMessage(f"I'm getting this {language} error:"),
        base.UserMessage(error),
        base.AssistantMessage("I'll help. Can you share the relevant code?"),
    ]
```

---

## Transports

| Transport | Use case | Key option |
|-----------|----------|------------|
| **stdio** | Claude Desktop, local tools | `mcp.run()` (default) |
| **Streamable HTTP** | Production, remote, multi-node | `mcp.run(transport="streamable-http")` |
| **SSE** | Legacy only | `mcp.run(transport="sse")` ⚠️ deprecated |

### stdio — Claude Desktop config

```json
{
  "mcpServers": {
    "my-server": {
      "command": "uv",
      "args": ["run", "--with", "mcp", "mcp", "run", "/abs/path/to/server.py"],
      "env": { "API_KEY": "your-key" }
    }
  }
}
```
Always use **absolute paths**. Generated automatically by `uv run mcp install server.py`.

### Streamable HTTP — production

```python
mcp = FastMCP("App", stateless_http=True, json_response=True)
mcp.run(transport="streamable-http")  # http://localhost:8000/mcp
```

**Add to Claude Code:** `claude mcp add --transport http my-server http://localhost:8000/mcp`

**ASGI mounting (multi-server):**
```python
import contextlib
from starlette.applications import Starlette
from starlette.routing import Mount

api = FastMCP("API", stateless_http=True, json_response=True)
api.settings.streamable_http_path = "/"   # endpoint: /api, not /api/mcp

@contextlib.asynccontextmanager
async def lifespan(app):
    async with api.session_manager.run():
        yield

app = Starlette(routes=[Mount("/api", api.streamable_http_app())], lifespan=lifespan)
# uvicorn app:app
```

For full ASGI details, CORS config, and host-based routing → see `references/transports-and-client.md`.

---

## MCP CLI

```bash
uv run mcp dev server.py                    # MCP Inspector (interactive test)
uv run mcp dev server.py --with pandas      # with extra deps
uv run mcp dev server.py --with-editable .  # editable local package
uv run mcp run server.py                    # direct stdio run
uv run mcp install server.py                # register in Claude Desktop
uv run mcp install server.py --name "My Server" -v API_KEY=abc -f .env
```

> `mcp dev` and `mcp run` only work with **FastMCP** servers — not the low-level `Server` class.

---

## MCP Client

```python
import asyncio
from mcp import ClientSession, StdioServerParameters, types
from mcp.client.stdio import stdio_client
from mcp.client.streamable_http import streamable_http_client

# stdio client
async def main():
    params = StdioServerParameters(command="python", args=["server.py"])
    async with stdio_client(params) as (r, w):
        async with ClientSession(r, w) as session:
            await session.initialize()               # always first
            tools = await session.list_tools()
            result = await session.call_tool("add", {"a": 1, "b": 2})
            print(result.content[0].text)

# Streamable HTTP client
async with streamable_http_client("http://localhost:8000/mcp") as (r, w, _):
    async with ClientSession(r, w) as session:
        await session.initialize()
        ...
```

For OAuth-protected servers, sampling callbacks, SSE client → see `references/transports-and-client.md`.

---

## Top Pitfalls

1. **stdout pollution** — never `print()` to stdout in a stdio server; it breaks the protocol. Use `ctx.info()` or `ctx.debug()` instead.
2. **Missing `await session.initialize()`** — all client calls fail silently.
3. **Relative paths in Claude Desktop config** — always use absolute paths.
4. **Missing `uv run` prefix** — when in a uv project, prefix all CLI commands.
5. **`mcp` without `[cli]`** — `mcp dev/run/install` commands not available.
6. **Forgetting `stateless_http=True`** in multi-node HTTP deployments — sessions not shared across instances.
7. **Missing `session_manager.run()`** in ASGI mounting — server silently stops working.
8. **Sync tool with `await`** — make the tool `async def` when using `ctx` methods.
9. **Lifespan context is `None`** when no `lifespan=` was passed to `FastMCP`.
10. **`mcp run` with low-level `Server`** — not supported; use `python server.py` directly.

---

## Reference Files

Load the relevant file when you need deeper detail:

| File | When to load |
|------|-------------|
| `references/context-lifespan.md` | Lifespan pattern, Context API, progress/logging, resource notifications |
| `references/transports-and-client.md` | ASGI mounting, CORS, SSE, full client API, OAuth client |
| `references/advanced-features.md` | Elicitation, Sampling, Image content, Structured output details |
| `references/auth-and-lowlevel.md` | OAuth 2.1 server auth (TokenVerifier), low-level Server API |
