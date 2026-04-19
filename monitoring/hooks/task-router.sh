#!/bin/bash
# task-router.sh - Intelligent task routing via UserPromptSubmit
# Zero-dependency: pure bash, no jq required.
# Analyzes the user prompt and emits a routing hint for the model to consume.
# Exit is always 0: this hook must never block a user prompt.

set -u

INPUT=$(cat 2>/dev/null || true)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LOG_DIR="${HOME}/.claude/logs"
ROUTER_LOG="${LOG_DIR}/task-router.jsonl"

mkdir -p "$LOG_DIR" 2>/dev/null || true

# Best-effort extraction of user_prompt and session_id without jq.
# Claude Code sends JSON; we match the flat string field and strip quotes.
USER_PROMPT=$(printf '%s' "$INPUT" | grep -oE '"user_prompt"[[:space:]]*:[[:space:]]*"([^"\\]|\\.)*"' | head -1 | sed -E 's/^"user_prompt"[[:space:]]*:[[:space:]]*"(.*)"$/\1/')
SESSION_ID=$(printf '%s' "$INPUT" | grep -oE '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"([^"]*)"$/\1/')
SESSION_ID="${SESSION_ID:-unknown}"

# Normalise prompt to lowercase for pattern matching.
PROMPT_LOWER=$(printf '%s' "$USER_PROMPT" | tr '[:upper:]' '[:lower:]')

ROUTE=""
AGENT=""
CONFIDENCE="low"

# Patterns ordered most specific -> least specific.
if printf '%s' "$PROMPT_LOWER" | grep -qE '(build (fail|error|broken)|compile error|type error|typescript error|lint error|cannot find module)'; then
  ROUTE="build-fix"; AGENT="build-error-resolver"; CONFIDENCE="high"
elif printf '%s' "$PROMPT_LOWER" | grep -qE '(build me a|create a new|implement a |add a .* feature|new project|scaffold|bootstrap)'; then
  ROUTE="plan-first"; AGENT="planner"; CONFIDENCE="high"
elif printf '%s' "$PROMPT_LOWER" | grep -qE '(architect|system design|how should (i|we) (structure|design)|microservice|monolith)'; then
  ROUTE="architecture"; AGENT="architect"; CONFIDENCE="high"
elif printf '%s' "$PROMPT_LOWER" | grep -qE '(fix (this|the|a) bug|is broken|not working|doesn.t work|is crashing|keeps? (failing|crashing))'; then
  ROUTE="debug"; AGENT="tdd-guide"; CONFIDENCE="high"
elif printf '%s' "$PROMPT_LOWER" | grep -qE '(debug this|investigate (this|the|why)|diagnose|figure out why)'; then
  ROUTE="debug"; AGENT="tdd-guide"; CONFIDENCE="medium"
elif printf '%s' "$PROMPT_LOWER" | grep -qE '(write tests? for|add tests? (for|to)|test coverage|unit test|integration test|e2e test)'; then
  ROUTE="tdd"; AGENT="tdd-guide"; CONFIDENCE="high"
elif printf '%s' "$PROMPT_LOWER" | grep -qE '(security (review|audit|scan|check)|vulnerabilit|find (injection|xss|csrf)|owasp|penetration test)'; then
  ROUTE="security"; AGENT="security-reviewer"; CONFIDENCE="high"
elif printf '%s' "$PROMPT_LOWER" | grep -qE '(review (this|my|the) (code|changes|pr|pull request)|code review|look over (this|my))'; then
  ROUTE="review"; AGENT="code-reviewer"; CONFIDENCE="high"
elif printf '%s' "$PROMPT_LOWER" | grep -qE '(refactor (this|the)|clean up|remove dead code|remove unused|consolidate)'; then
  ROUTE="refactor"; AGENT="refactor-cleaner"; CONFIDENCE="medium"
elif printf '%s' "$PROMPT_LOWER" | grep -qE '(write (the |a )?(docs|documentation|readme)|update (the )?(docs|documentation|readme)|add (jsdoc|docstring))'; then
  ROUTE="docs"; AGENT="doc-updater"; CONFIDENCE="medium"
elif printf '%s' "$PROMPT_LOWER" | grep -qE '(optimize (this|the|for)|speed up|fix.*bottleneck|reduce.*latency|memory leak|profil(e|ing) (this|the))'; then
  ROUTE="performance"; AGENT="architect"; CONFIDENCE="medium"
fi

# Route hint → injected as system context for the model.
if [ -n "$ROUTE" ] && [ "$CONFIDENCE" != "low" ]; then
  case "$ROUTE" in
    plan-first)   HINT="New feature — consider /plan then /tdd." ;;
    architecture) HINT="Architecture question — the architect agent can help." ;;
    debug)        HINT="Bug detected — the tdd-guide agent reproduces with a test first, then fixes." ;;
    tdd)          HINT="Testing task — /tdd runs RED-GREEN-REFACTOR with 80%+ coverage." ;;
    security)     HINT="Security-sensitive — security-reviewer should review before commit." ;;
    review)       HINT="Code review — code-reviewer checks quality, security, maintainability." ;;
    refactor)     HINT="Refactor — refactor-cleaner finds dead code and consolidation opportunities." ;;
    build-fix)    HINT="Build error — build-error-resolver makes minimal surgical fixes." ;;
    docs)         HINT="Docs task — doc-updater generates and updates codemaps." ;;
    performance)  HINT="Performance — profile first before optimising." ;;
    *)            HINT="" ;;
  esac

  echo "[task-router] Route: ${ROUTE} | Agent: ${AGENT} (confidence: ${CONFIDENCE})"
  [ -n "$HINT" ] && echo "Hint: $HINT"

  # Truncate prompt preview to 200 chars and strip newlines for single-line JSON.
  PREVIEW=$(printf '%s' "$USER_PROMPT" | tr '\n' ' ' | cut -c1-200 | sed 's/"/\\"/g')
  printf '{"timestamp":"%s","session_id":"%s","route":"%s","agent":"%s","confidence":"%s","prompt_preview":"%s"}\n' \
    "$TIMESTAMP" "$SESSION_ID" "$ROUTE" "$AGENT" "$CONFIDENCE" "$PREVIEW" \
    >> "$ROUTER_LOG" 2>/dev/null || true
fi

exit 0
