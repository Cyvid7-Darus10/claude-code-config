# Agent Instructions

Curated setup (trimmed 2026-07-06 — full previous config in `~/.claude/backups/pre-cleanup-2026-07-06.tar.gz`).

## Core Principles

1. **Security-First** — never hardcode secrets; validate all inputs
2. **Test-Driven** — write tests before implementation
3. **Immutability** — prefer new objects over mutation (except where language idioms differ, e.g. Go)

## Available Agents

| Agent | When to Use |
|-------|-------------|
| planner | Complex features, refactoring |
| architect | Architectural decisions |
| tdd-guide | New features, bug fixes |
| code-reviewer | After writing/modifying code |
| security-reviewer | Before commits, sensitive code |
| build-error-resolver | When build fails |
| typescript-reviewer | TypeScript/JavaScript changes |
| python-reviewer | Python changes |
| database-reviewer | Schema design, query optimization (Postgres/Supabase) |
| docs-lookup | Library/API documentation questions |
| e2e-runner | Critical user flows |
| refactor-cleaner | Dead code cleanup |

Launch independent agents in parallel.
