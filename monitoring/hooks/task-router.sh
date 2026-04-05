#!/bin/bash
# task-router.sh - Intelligent task routing via UserPromptSubmit
# Analyzes user prompts and suggests the right agent/workflow automatically
# Inspired by ruflo's intelligent routing pattern (github.com/ruvnet/ruflo)

set -e

INPUT=$(cat)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LOG_DIR="${HOME}/.claude/logs"
ROUTER_LOG="${LOG_DIR}/task-router.jsonl"

mkdir -p "$LOG_DIR"

USER_PROMPT=$(echo "$INPUT" | jq -r '.user_prompt // ""')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')

# Normalize prompt to lowercase for matching
PROMPT_LOWER=$(echo "$USER_PROMPT" | tr '[:upper:]' '[:lower:]')

ROUTE=""
AGENT=""
CONFIDENCE="low"

# --- Pattern matching for routing ---
# Patterns are ordered from most specific to least specific.
# We require strong intent signals to avoid false positives on conversational prompts.

# Build errors (very specific patterns, check first)
if echo "$PROMPT_LOWER" | grep -qE '(build (fail|error|broken)|compile error|type error|typescript error|lint error|cannot find module)'; then
  ROUTE="build-fix"
  AGENT="build-error-resolver"
  CONFIDENCE="high"

# Planning & Architecture (require imperative verbs + object)
elif echo "$PROMPT_LOWER" | grep -qE '(build me a|create a new|implement a |add a .* feature|new project|scaffold|bootstrap)'; then
  ROUTE="plan-first"
  AGENT="planner"
  CONFIDENCE="high"
elif echo "$PROMPT_LOWER" | grep -qE '(architect|system design|how should (i|we) (structure|design)|microservice|monolith)'; then
  ROUTE="architecture"
  AGENT="architect"
  CONFIDENCE="high"

# Bug fixing & Debugging (require action-oriented phrasing)
elif echo "$PROMPT_LOWER" | grep -qE '(fix (this|the|a) bug|is broken|not working|doesn.t work|is crashing|keeps? (failing|crashing))'; then
  ROUTE="debug"
  AGENT="tdd-guide"
  CONFIDENCE="high"
elif echo "$PROMPT_LOWER" | grep -qE '(debug this|investigate (this|the|why)|diagnose|figure out why)'; then
  ROUTE="debug"
  AGENT="tdd-guide"
  CONFIDENCE="medium"

# Testing (explicit test requests)
elif echo "$PROMPT_LOWER" | grep -qE '(write tests? for|add tests? (for|to)|test coverage|unit test|integration test|e2e test)'; then
  ROUTE="tdd"
  AGENT="tdd-guide"
  CONFIDENCE="high"

# Security (explicit security work, not just mentioning "auth")
elif echo "$PROMPT_LOWER" | grep -qE '(security (review|audit|scan|check)|vulnerabilit|find (injection|xss|csrf)|owasp|penetration test)'; then
  ROUTE="security"
  AGENT="security-reviewer"
  CONFIDENCE="high"

# Code review (explicit review requests)
elif echo "$PROMPT_LOWER" | grep -qE '(review (this|my|the) (code|changes|pr|pull request)|code review|look over (this|my))'; then
  ROUTE="review"
  AGENT="code-reviewer"
  CONFIDENCE="high"

# Refactoring
elif echo "$PROMPT_LOWER" | grep -qE '(refactor (this|the)|clean up|remove dead code|remove unused|consolidate)'; then
  ROUTE="refactor"
  AGENT="refactor-cleaner"
  CONFIDENCE="medium"

# Documentation (explicit doc requests)
elif echo "$PROMPT_LOWER" | grep -qE '(write (the |a )?(docs|documentation|readme)|update (the )?(docs|documentation|readme)|add (jsdoc|docstring))'; then
  ROUTE="docs"
  AGENT="doc-updater"
  CONFIDENCE="medium"

# Performance (require action context, not just mentioning "slow")
elif echo "$PROMPT_LOWER" | grep -qE '(optimize (this|the|for)|speed up|fix.*bottleneck|reduce.*latency|memory leak|profil(e|ing) (this|the))'; then
  ROUTE="performance"
  AGENT="architect"
  CONFIDENCE="medium"
fi

# --- Output routing suggestion ---

if [ -n "$ROUTE" ] && [ "$CONFIDENCE" != "low" ]; then
  # Log the routing decision
  LOG_ENTRY=$(jq -nc \
    --arg ts "$TIMESTAMP" \
    --arg session "$SESSION_ID" \
    --arg route "$ROUTE" \
    --arg agent "$AGENT" \
    --arg confidence "$CONFIDENCE" \
    --arg prompt "${USER_PROMPT:0:200}" \
    '{
      timestamp: $ts,
      session_id: $session,
      route: $route,
      suggested_agent: $agent,
      confidence: $confidence,
      prompt_preview: $prompt
    }')

  echo "$LOG_ENTRY" >> "$ROUTER_LOG"

  # Build workflow hints based on route
  case "$ROUTE" in
    plan-first)
      HINT="This looks like a new feature request. Consider: /plan to create an implementation plan, then /tdd for test-driven development." ;;
    architecture)
      HINT="Architecture question detected. The architect agent can help with system design decisions." ;;
    debug)
      HINT="Bug/debugging detected. The tdd-guide agent enforces: reproduce with a test first, then fix. Use /tdd for the full workflow." ;;
    tdd)
      HINT="Testing task detected. Use /tdd for the full RED-GREEN-REFACTOR cycle with 80%+ coverage." ;;
    security)
      HINT="Security-sensitive task detected. The security-reviewer agent should review any changes before committing." ;;
    review)
      HINT="Code review requested. The code-reviewer agent will check quality, security, and maintainability." ;;
    refactor)
      HINT="Refactoring task detected. The refactor-cleaner agent can identify dead code and consolidation opportunities." ;;
    build-fix)
      HINT="Build error detected. The build-error-resolver agent specializes in minimal, surgical fixes to get builds green." ;;
    docs)
      HINT="Documentation task detected. The doc-updater agent can generate and update docs and codemaps." ;;
    performance)
      HINT="Performance concern detected. Consider profiling first before optimizing." ;;
  esac

  # Output as system context (injected into conversation)
  echo "[task-router] Route: ${ROUTE} | Suggested agent: ${AGENT} (confidence: ${CONFIDENCE})"
  echo "Hint: ${HINT}"
fi

# Always pass through — never block
exit 0
