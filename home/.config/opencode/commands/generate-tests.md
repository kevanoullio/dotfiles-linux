---
description: Generates a companion testing spec suite for the current file or plan.
agent: test_specialist
subtask: true
---
Initialize a comprehensive testing suite generation pipeline for this target code module.

### Step 1: Inject Testing Standards

skill({ name: "testing-standards" })

### Step 2: Live Repository Context Capture

Gather active testing ecosystem properties from the workspace to detect framework choices, conventions, and configuration settings:

- **Test Configurations:** !`find . -maxdepth 2 \( -name "*test*" -o -name "*spec*" -o -name "jest*" -o -name "vitest*" -o -name "pytest*" \) -not -path '*/.*' -not -path './node_modules' | sort | head -n 15`
- **Ecosystem Test Manifest Hooks:** !`[ -f package.json ] && grep -E '"(jest|vitest|playwright|cypress|mocha|pytest)"' package.json || [ -f Cargo.toml ] && grep -i "test" Cargo.toml || echo "No explicit test dependencies highlighted in main configuration file."`

### Step 3: Test Suite Synthesis Assignment

Compare your captured project testing configurations against the targeted code file or functional plan[cite: 2].

Instruct your subagent process to synthesize this context into a complete, highly-isolated testing block with explicit assertions covering edge cases, failure states, boundary conditions, and core operations[cite: 2]. Generate either unit tests, integration tests, or end-to-end tests based explicitly on what the user has instructed in the active prompt session[cite: 2].

Generate the output block cleanly matching the schema below:

# 🧪 Test Suite Execution Blueprint

## 1. 🔍 Test Coverage Strategy

*Outline the exact test boundaries and cases being verified:*

- [e.g., Unit tests for error handling; mocked external database connection matrix; boundary state verification for empty input profiles]

## 2. 📄 Complete Target Test File Payload

Provide the complete, ready-to-write test suite code below. Do not use placeholders, shorthand comments, or truncation:

```[language_id]
[Insert absolute complete, raw test code content here. Ensure imports, mocks, setup/teardown blocks, and assertions are fully written out.]
