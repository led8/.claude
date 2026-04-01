"""Async LiteLLM chat client."""

from __future__ import annotations

import logging
from typing import Any

import httpx
import tenacity
from pydantic import BaseModel, Field, SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict

logger = logging.getLogger(__name__)


class LiteLlmSettings(BaseSettings):
    """Environment-driven settings for LiteLLM chat completions."""

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    url: str = Field(validation_alias="LITE_LLM_URL")
    key: SecretStr = Field(validation_alias="LITE_LLM_KEY")
    model: str = Field(validation_alias="LITE_LLM_MODEL")
    timeout_seconds: float = Field(default=30.0, validation_alias="LITE_LLM_TIMEOUT_SECONDS")
    verify_ssl: bool = Field(default=True, validation_alias="LITE_LLM_VERIFY_SSL")


class ChatMessage(BaseModel):
    """One chat message."""

    role: str
    content: str


def build_async_client(settings: LiteLlmSettings) -> httpx.AsyncClient:
    """Create an AsyncClient configured from LiteLLM settings."""

    return httpx.AsyncClient(timeout=settings.timeout_seconds, verify=settings.verify_ssl)


def is_retryable_http_error(exc: BaseException) -> bool:
    """Retry network failures and transient 5xx responses."""
    if isinstance(exc, httpx.RequestError):
        return True
    if isinstance(exc, httpx.HTTPStatusError):
        return exc.response.status_code >= 500
    return False


@tenacity.retry(
    wait=tenacity.wait_exponential(multiplier=1, min=1, max=10),
    stop=tenacity.stop_after_attempt(3),
    retry=tenacity.retry_if_exception(is_retryable_http_error),
    reraise=True,
)
async def chat_completion(
    client: httpx.AsyncClient,
    settings: LiteLlmSettings,
    messages: list[ChatMessage],
    *,
    temperature: float = 0.0,
) -> str:
    """Call LiteLLM chat completions endpoint and return assistant content."""
    url = f"{settings.url.rstrip('/')}/chat/completions"
    payload: dict[str, Any] = {
        "model": settings.model,
        "messages": [message.model_dump(mode="json") for message in messages],
        "temperature": temperature,
    }
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {settings.key.get_secret_value()}",
    }
    response = await client.post(url, json=payload, headers=headers)
    response.raise_for_status()
    body = response.json()
    if not isinstance(body, dict):
        raise RuntimeError("Unexpected LiteLLM response type")

    choices = body.get("choices")
    if not isinstance(choices, list) or not choices:
        raise RuntimeError("LiteLLM response has no choices")

    first_choice = choices[0]
    if not isinstance(first_choice, dict):
        raise RuntimeError("LiteLLM response choice format is invalid")

    message = first_choice.get("message")
    if not isinstance(message, dict):
        raise RuntimeError("LiteLLM response has no assistant message")

    content = message.get("content")
    if not isinstance(content, str):
        raise RuntimeError("LiteLLM response assistant content is not text")

    return content
