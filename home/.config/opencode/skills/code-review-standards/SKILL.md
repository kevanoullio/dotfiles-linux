# 🛠️ Universal Code Review Engineering Standards

When executing a code review or logical audit, you must strictly evaluate the target files or diff patches against the following foundational software engineering pillars.

## 1. 🔐 Security & Defensive Guardrails

- **Injection Vectors:** Inspect inputs for unvalidated data, missing SQL parameters, unsafe string concatenations in command executions, or cross-site scripting (XSS) risks.
- **Credential Safety:** Flag any hardcoded API keys, bearer tokens, secrets, encryption salts, or plain-text credentials.
- **Exception Resilience:** Ensure async operations, external API calls, and disk I/O operations are wrapped inside robust `try/catch` or language-native error-handling blocks.

## 2. 🧠 Logic, Concurrency & Correctness

- **State Mutability & Race Conditions:** In multi-threaded or asynchronous loops, verify that resource modifications are atomic or properly guarded to prevent deadlocks and race conditions.
- **Boundary Exhaustion:** Audit loop terminations, array slice indexes, and pagination boundaries to explicitly eliminate off-by-one errors or integer overflows.
- **Strict Equality & Types:** Enforce precise type comparison checks and intercept implicit type coercion bugs before they can manifest at runtime.

## 3. ⚡ Resource Management & Performance

- **Memory Optimization:** Isolate unclosed file descriptors, dangling event listeners, orphaned database pool connections, or infinite closures that trigger runtime memory leaks.
- **Algorithmic Complexity:** Identify nested loops running over unindexed datasets ($O(N^2)$ or worse) and propose streamlined, flat map transformations or database index updates.
- **I/O Operations:** Ensure database or external network requests are batched where applicable to prevent "N+1 query" anti-patterns.

## 4. 📐 Architecture, Style & Idioms

- **Single Responsibility Principle:** Flag functions or classes attempting to execute multiple distinct business logic layers, and outline exact logical breaking points.
- **Naming Conventions:** Enforce strict semantic clarity for variable, function, and class names (e.g., camelCase for TypeScript, snake_case for Python) according to native repository layouts.
- **Dead Code Elimination:** Intercept unused imports, orphaned variables, deprecated method calls, and debug logging statements that should not enter production.
