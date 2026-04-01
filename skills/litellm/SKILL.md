---
name: litellm
description: Build and troubleshoot async LiteLLM chat completion clients with httpx, pydantic-settings, and tenacity retries. Use when Codex needs to call LiteLLM /chat/completions, load model/auth from environment variables, handle transient network or HTTP 5xx failures, and validate OpenAI-compatible response payloads before returning assistant text.
---

# LiteLLM

## Overview

Use `scripts/litellm_client.py` as the default pattern for async LiteLLM chat completions with retries and strict response validation.

## Workflow

1. Load settings from environment variables with `LiteLlmSettings`.
2. Build request messages with `ChatMessage`.
3. Create a client using `build_async_client(settings)`.
4. Call `chat_completion(...)` and consume returned assistant text.
5. Handle `httpx.HTTPStatusError` and `RuntimeError` at caller level.

## Environment Variables

- `LITE_LLM_URL`: LiteLLM base URL, for example `http://localhost:4000`.
- `LITE_LLM_KEY`: API key used for bearer auth.
- `LITE_LLM_MODEL`: Model name sent in the payload.
- `LITE_LLM_TIMEOUT_SECONDS`: Optional timeout in seconds. Default: `30.0`.
- `LITE_LLM_VERIFY_SSL`: Optional TLS verification flag. Default: `true`.

## Guardrails

- Never print API keys or full authorization headers.
- Retry only transient failures (`RequestError` and HTTP 5xx).
- Preserve strict response shape checks before returning assistant content.
- Keep payload OpenAI-compatible (`model`, `messages`, `temperature`).

## Adaptation Notes

- Add extra request fields (`max_tokens`, `top_p`, tools) only when required.
- Keep the function return contract as plain text unless raw JSON is requested.
- Reuse `is_retryable_http_error` when adding other LiteLLM endpoints.
