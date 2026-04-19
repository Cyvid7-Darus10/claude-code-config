# Multi-Repo Consistency

For engineers working across multiple repositories with different tech stacks. The goal is that Claude's **judgement and style stay consistent across all your projects**, even when the languages differ.

## Core principle

**Consistency is a force multiplier.** If Claude handles errors one way in your Go service and a different way in your TypeScript service, you carry the mental tax of switching contexts every time you review code. These rules codify the invariants that transfer across stacks.

## Cross-stack invariants

These apply to every repo, regardless of language. Language-specific files under `rules/<lang>/` extend but do not override these.

### 1. Naming
- **Casing follows the language's community convention.** Go: `CamelCase` for exported, `camelCase` for unexported. Python: `snake_case`. TypeScript: `camelCase` for variables/functions, `PascalCase` for types/classes. Don't fight the ecosystem.
- **Meaning stays identical.** A function called `resolveUser` in TypeScript should be `resolve_user` in Python and `ResolveUser` in Go — same responsibility, same shape of inputs/outputs.
- **Avoid abbreviations** unless they're domain-standard (`id`, `url`, `http` are fine; `usr`, `cfg`, `mgr` are not).

### 2. Error handling
- **Explicit over implicit.** Never silently swallow. Either handle it meaningfully or propagate it with added context.
- **Distinguish programmer errors from operational errors.** Programmer errors (invariant violations, nil deref) should crash loudly. Operational errors (network timeout, validation) should return structured errors.
- **Error messages name the operation that failed**, not just the symptom. `"failed to upsert user: duplicate email"` beats `"duplicate email"`.

### 3. Logging
- **Structured, not printf.** Every log line must be machine-parseable with consistent fields.
- **Required fields everywhere**: timestamp (UTC/ISO8601), level, request_id or trace_id, message. Everything else is context.
- **No PII or secrets in logs** — not emails, not tokens, not request bodies containing auth headers.
- **Level discipline**: `ERROR` = something needs attention, `WARN` = degraded but working, `INFO` = state changes worth knowing, `DEBUG` = temporary investigation only.

### 4. Boundaries
- **Validate at every trust boundary**, not just the outermost. Input crossing a service boundary, a queue, or a function that another service can call is untrusted.
- **Typed DTOs at HTTP / RPC / queue edges.** No passing raw maps, dicts, or JSON blobs through business logic. Parse at the edge, work with typed structs.
- **Never return database rows directly to API clients.** Transform into a DTO. Schema change should not silently change the public API.

### 5. Concurrency
- **Shared mutable state requires explicit coordination** — a mutex, a channel, an actor, a transaction, a CAS. Never rely on "it's fast enough that it won't race."
- **Cancellation propagates.** Every request-scoped operation accepts the caller's cancellation (context in Go, AbortSignal in JS, asyncio task in Python). No orphaned work.

### 6. Testing
- **Tests describe behavior, not implementation.** Test names read as sentences: `user_with_unverified_email_cannot_log_in`, not `test_login_1`.
- **Integration tests use real databases**, not mocks. Mocks mask drift between test and prod.
- **Flaky tests are bugs.** A flaky test is worse than no test — it trains you to ignore failures. Quarantine or fix immediately.

### 7. Configuration
- **Never commit secrets.** Use `.env.example` with placeholder values; `.env` is gitignored.
- **Config validated at startup**, not on first use. Fail fast at boot if something required is missing.
- **Environment-derived, not hardcoded.** Even "default" values belong in config.

### 8. Commits & PRs
- **Conventional commits**: `feat|fix|refactor|docs|test|chore|perf|ci: <description>`.
- **One logical change per PR.** If the PR description needs bullet points about unrelated changes, split it.
- **PR description explains WHY**, not WHAT (the diff shows what).

## Language-specific extensions

Each language folder in `rules/` extends these invariants with idiomatic patterns:

- `rules/golang/` — idiomatic Go, including pointer receivers (intentional override of common immutability default).
- `rules/typescript/` — TypeScript typing, Node/web specifics.
- `rules/python/` — PEP 8, type hints, async patterns.
- `rules/rust/` — ownership, error handling, `?` operator patterns.
- `rules/kotlin/`, `rules/java/`, `rules/swift/`, `rules/cpp/`, `rules/php/`, `rules/perl/` — one folder per stack.

When a language extension conflicts with this file, the extension wins — specific beats general. Example: Go uses pointer receivers for struct mutation, which overrides the common immutability default.

## Apply this rule when

- Writing a PR description (include why the change preserves cross-repo consistency).
- Reviewing code that looks different from how we'd write it in another stack (ask: is the difference *justified* by the stack, or is it drift?).
- Onboarding a new repo (does it follow these invariants? If not, write down the intentional deviation).
