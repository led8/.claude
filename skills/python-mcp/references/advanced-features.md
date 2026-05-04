# Advanced Features

## Elicitation (v1.23.0+)

Pause a tool mid-execution to request structured input from the user.

### Form Mode — structured non-sensitive input

```python
import uuid
from pydantic import BaseModel, Field
from mcp.server.fastmcp import Context, FastMCP
from mcp.server.session import ServerSession

mcp = FastMCP("Elicitation Example")

class BookingPreferences(BaseModel):
    checkAlternative: bool = Field(description="Try another date?")
    alternativeDate: str = Field(default="2024-12-26", description="Date YYYY-MM-DD")

@mcp.tool()
async def book_table(date: str, party_size: int, ctx: Context[ServerSession, None]) -> str:
    """Book a restaurant table."""
    if date == "2024-12-25":
        result = await ctx.elicit(
            message=f"No tables for {party_size} on {date}. Check alternative?",
            schema=BookingPreferences,
        )
        if result.action == "accept" and result.data:
            return f"Booked for {result.data.alternativeDate}" if result.data.checkAlternative else "Cancelled"
        return "Booking cancelled"
    return f"Booked for {date}"
```

`result.action` → `"accept"` | `"decline"` | `"cancel"` — always handle all three.
`result.data` → `None` unless `action == "accept"`.

### URL Mode — OAuth flows, payments, credentials

```python
from mcp.shared.exceptions import UrlElicitationRequiredError
from mcp.types import ElicitRequestURLParams

@mcp.tool()
async def connect_service(service: str, ctx: Context[ServerSession, None]) -> str:
    """Connect to a third-party service."""
    eid = str(uuid.uuid4())
    # Raise before any work — signals client to open URL first
    raise UrlElicitationRequiredError([
        ElicitRequestURLParams(
            mode="url",
            message=f"Authorize access to {service}",
            url=f"https://{service}.example.com/oauth/authorize?id={eid}",
            elicitationId=eid,
        )
    ])
```

> **Security:** Never use form elicitation for passwords or API keys — use URL mode.
> Always treat `result.data` as untrusted input; validate before use.

---

## Sampling

Request an LLM completion from the connected client (server-initiated AI reasoning).

### Server side

```python
from mcp.types import SamplingMessage, TextContent

@mcp.tool()
async def generate_poem(topic: str, ctx: Context[ServerSession, None]) -> str:
    """Generate a poem via the client's LLM."""
    result = await ctx.session.create_message(
        messages=[
            SamplingMessage(
                role="user",
                content=TextContent(type="text", text=f"Write a short poem about {topic}"),
            )
        ],
        max_tokens=200,
        include_context="thisServer",  # give LLM access to server resources
    )
    return result.content.text if result.content.type == "text" else str(result.content)
```

### Client side — sampling_callback required

```python
from mcp import ClientSession, types
from mcp.shared.context import RequestContext

async def sampling_callback(
    ctx: RequestContext[ClientSession, None],
    params: types.CreateMessageRequestParams,
) -> types.CreateMessageResult:
    # Call your LLM here (OpenAI, Anthropic, etc.)
    response_text = call_my_llm(params.messages)
    return types.CreateMessageResult(
        role="assistant",
        content=types.TextContent(type="text", text=response_text),
        model="claude-3-5-sonnet",
        stopReason="endTurn",
    )

async with ClientSession(r, w, sampling_callback=sampling_callback) as session:
    await session.initialize()
    ...
```

> Without `sampling_callback`, `ctx.session.create_message()` hangs indefinitely.
> Sampling costs tokens on the **client's** LLM account — don't abuse from untrusted servers.

---

## Image Content

```python
from mcp.server.fastmcp import FastMCP, Image
from mcp.types import CallToolResult, TextContent, ImageContent
import base64, io

mcp = FastMCP("Image Example")

# Simple: return Image helper (handles encoding automatically)
@mcp.tool()
def create_thumbnail(image_path: str) -> Image:
    """Create a thumbnail."""
    from PIL import Image as PILImage
    img = PILImage.open(image_path)
    img.thumbnail((100, 100))
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    return Image(data=buf.getvalue(), format="png")

# Advanced: image + caption
@mcp.tool()
def chart_with_caption(title: str) -> CallToolResult:
    """Return a chart with a caption."""
    chart_bytes = generate_chart_bytes(title)  # your chart lib
    return CallToolResult(content=[
        TextContent(type="text", text=f"Chart: {title}"),
        ImageContent(
            type="image",
            data=base64.b64encode(chart_bytes).decode(),
            mimeType="image/png",
        ),
    ])
```

**Client-side parsing:**
```python
from mcp.types import ImageContent
import base64

for item in result.content:
    if isinstance(item, ImageContent):
        img_bytes = base64.b64decode(item.data)
        open("output.png", "wb").write(img_bytes)
```

> `ImageContent.data` must be a **base64 string**, not raw bytes.
> Compress images before returning — large payloads cause timeouts over stdio.
> Validate `image_path` inputs to prevent path traversal attacks.

---

## Notifications & Progress

```python
from mcp.server.fastmcp import Context, FastMCP
from mcp.server.session import ServerSession

mcp = FastMCP("Notifications")

@mcp.tool()
async def long_task(name: str, steps: int, ctx: Context[ServerSession, None]) -> str:
    """Long-running task with progress."""
    await ctx.info(f"Starting: {name}")

    for i in range(steps):
        # ... do work ...
        await ctx.report_progress(progress=(i+1)/steps, total=1.0, message=f"Step {i+1}/{steps}")
        await ctx.debug(f"Step {i+1} completed")

    await ctx.info("Done!")
    return f"Completed: {name}"

@mcp.tool()
async def update_resource(uri: str, ctx: Context[ServerSession, None]) -> str:
    """Update data and notify clients."""
    # ... do update ...
    from pydantic import AnyUrl
    await ctx.session.send_resource_updated(AnyUrl(uri))
    await ctx.session.send_resource_list_changed()
    return f"Updated {uri}"
```

> **Never use `print()`** in a stdio server — it corrupts the protocol stream. Always use `ctx.info/debug/warning/error()`.
> Progress and list-change notifications require a **stateful** connection — not available in `stateless_http=True` mode.
> Avoid high-frequency progress calls in tight loops — flood the client with notifications.

---

## Structured Output — Advanced Patterns

For the basic patterns, see the SKILL.md tools section.

### Direct CallToolResult (full control + `_meta`)

```python
from typing import Annotated
from mcp.types import CallToolResult, TextContent
from pydantic import BaseModel

class MyOutput(BaseModel):
    status: str
    value: int

@mcp.tool()
def advanced_tool() -> Annotated[CallToolResult, MyOutput]:
    """Return structured + meta data."""
    return CallToolResult(
        content=[TextContent(type="text", text="Visible to model")],
        structuredContent={"status": "ok", "value": 42},
        _meta={"hidden": "data for client apps only — not shown to LLM"},
    )
```

### Low-level structured output with outputSchema

```python
import mcp.types as types

@server.list_tools()
async def list_tools() -> list[types.Tool]:
    return [types.Tool(
        name="get_stats",
        description="Get statistics",
        inputSchema={"type": "object", "properties": {"id": {"type": "string"}}, "required": ["id"]},
        outputSchema={
            "type": "object",
            "properties": {"mean": {"type": "number"}, "count": {"type": "integer"}},
            "required": ["mean", "count"],
        },
    )]

@server.call_tool()
async def call_tool(name: str, arguments: dict) -> dict:
    return {"mean": 42.5, "count": 100}  # validated against outputSchema
```
