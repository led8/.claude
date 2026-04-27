# Python Code Examples

## FastAPI

- Always use `async def` for routes
- **Never hardcode URL paths** — always use `request.url_for()` for URL generation

```python
from fastapi import FastAPI
import uvicorn

app = FastAPI()

@app.get("/health", status_code=200)
async def healthcheck():
    return "ok"

if __name__ == "__main__":
    uvicorn.run(app, host='0.0.0.0', port=8080)
```

## Click CLI

```python
import click

@click.command()
@click.option('--host', default="127.0.0.1", help='Server host.')
@click.option('--port', default=8080, help='Server port.')
def run(host: str, port: int) -> None:
    """Run the server."""
    uvicorn.run(app, host=host, port=port)

if __name__ == '__main__':
    run()
```

## Sentry

**Do not add Sentry by default.** Only when explicitly asked for error tracking.

```bash
uv add 'sentry-sdk' --optional sentry
```

Activate only when `SENTRY_DSN` is set:

```python
import os

try:
    import sentry_sdk
    if sentry_dsn := os.getenv("SENTRY_DSN"):
        sentry_sdk.init(dsn=sentry_dsn, traces_sample_rate=1.0)
except ImportError:
    pass
```
