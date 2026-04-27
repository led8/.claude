#!/usr/bin/env bash
set -euo pipefail

die() {
  echo "agent-memory wrapper: $*" >&2
  exit 1
}

is_executable() {
  [[ -n "${1:-}" && -x "$1" ]]
}

detect_tool_home_from_bin() {
  local bin="$1"
  if [[ "$bin" == */.venv/bin/neo4j-agent-memory ]]; then
    cd "$(dirname "$bin")/../.." && pwd
  fi
}

find_candidate_home() {
  local candidate

  if [[ -n "${AGENT_MEMORY_HOME:-}" && -x "${AGENT_MEMORY_HOME}/.venv/bin/neo4j-agent-memory" ]]; then
    cd "$AGENT_MEMORY_HOME" && pwd
    return 0
  fi

  for candidate in \
    "$PWD/agent-memory" \
    "$HOME/agent-memory" \
    "$HOME/code/agent-memory" \
    "$HOME/src/agent-memory" \
    "$HOME/projects/agent-memory" \
    "$HOME"/code/*/agent-memory \
    "$HOME"/code/*/*/agent-memory \
    "$HOME"/code/*/*/*/agent-memory \
    "$HOME"/src/*/agent-memory \
    "$HOME"/src/*/*/agent-memory \
    "$HOME"/projects/*/agent-memory \
    "$HOME"/projects/*/*/agent-memory
  do
    if [[ -d "$candidate" && -x "$candidate/.venv/bin/neo4j-agent-memory" ]]; then
      cd "$candidate" && pwd
      return 0
    fi
  done

  return 1
}

resolve_bin() {
  local home

  if is_executable "${AGENT_MEMORY_BIN:-}"; then
    printf '%s\n' "$AGENT_MEMORY_BIN"
    return 0
  fi

  if [[ -n "${AGENT_MEMORY_HOME:-}" && -x "${AGENT_MEMORY_HOME}/.venv/bin/neo4j-agent-memory" ]]; then
    printf '%s\n' "${AGENT_MEMORY_HOME}/.venv/bin/neo4j-agent-memory"
    return 0
  fi

  if command -v neo4j-agent-memory >/dev/null 2>&1; then
    command -v neo4j-agent-memory
    return 0
  fi

  if home="$(find_candidate_home 2>/dev/null)" && [[ -x "$home/.venv/bin/neo4j-agent-memory" ]]; then
    printf '%s\n' "$home/.venv/bin/neo4j-agent-memory"
    return 0
  fi

  return 1
}

derive_tool_home() {
  local bin="$1"
  local home

  if home="$(detect_tool_home_from_bin "$bin" 2>/dev/null)" && [[ -n "$home" ]]; then
    printf '%s\n' "$home"
    return 0
  fi

  if [[ -n "${AGENT_MEMORY_HOME:-}" && -d "${AGENT_MEMORY_HOME}" ]]; then
    cd "$AGENT_MEMORY_HOME" && pwd
    return 0
  fi

  if home="$(find_candidate_home 2>/dev/null)" && [[ -n "$home" ]]; then
    printf '%s\n' "$home"
    return 0
  fi

  return 1
}

source_env_if_present() {
  local tool_home="${1:-}"
  local env_file

  [[ -n "$tool_home" ]] || return 0
  env_file="$tool_home/.env"
  [[ -f "$env_file" ]] || return 0

  set -a
  # shellcheck disable=SC1090
  source "$env_file"
  set +a
}

has_embedder_flag() {
  local arg
  for arg in "$@"; do
    if [[ "$arg" == "--local-embedder" || "$arg" == "--hashed-local-embedder" ]]; then
      return 0
    fi
  done
  return 1
}

probe_neo4j_socket() {
  if bash -c 'exec 3<>/dev/tcp/127.0.0.1/7687' >/dev/null 2>&1; then
    return 0
  fi
  return 1
}

run_doctor() {
  local bin tool_home env_status socket_status help_status

  if ! bin="$(resolve_bin)"; then
    cat >&2 <<'EOF'
agent-memory wrapper doctor
- binary: missing
- next step: set AGENT_MEMORY_BIN or AGENT_MEMORY_HOME, or add neo4j-agent-memory to PATH
EOF
    exit 1
  fi

  tool_home="$(derive_tool_home "$bin" 2>/dev/null || true)"
  if [[ -n "$tool_home" && -f "$tool_home/.env" ]]; then
    env_status="found"
  else
    env_status="missing"
  fi

  if "$bin" memory --local-embedder --help >/dev/null 2>&1; then
    help_status="ok"
  else
    help_status="failed"
  fi

  if probe_neo4j_socket; then
    socket_status="reachable"
  else
    socket_status="unreachable"
  fi

  echo "agent-memory wrapper doctor"
  echo "- binary: $bin"
  echo "- tool_home: ${tool_home:-unknown}"
  echo "- env_file: $env_status"
  echo "- memory_cli: $help_status"
  echo "- neo4j_socket_127.0.0.1_7687: $socket_status"
  if [[ "$socket_status" != "reachable" ]]; then
    echo "- note: Neo4j access may need an escalated command when Codex runs in a sandbox"
  fi
}

main() {
  local bin tool_home
  local -a args

  if [[ "${1:-}" == "doctor" ]]; then
    run_doctor
    exit 0
  fi

  bin="$(resolve_bin)" || die "unable to find neo4j-agent-memory; set AGENT_MEMORY_BIN or AGENT_MEMORY_HOME, or add it to PATH"
  tool_home="$(derive_tool_home "$bin" 2>/dev/null || true)"

  source_env_if_present "$tool_home"

  args=("$@")
  if [[ "${args[0]:-}" == "memory" ]] && ! has_embedder_flag "${args[@]}"; then
    args=("memory" "--local-embedder" "${args[@]:1}")
  fi

  if [[ -n "$tool_home" ]]; then
    cd "$tool_home"
  fi

  exec "$bin" "${args[@]}"
}

main "$@"
