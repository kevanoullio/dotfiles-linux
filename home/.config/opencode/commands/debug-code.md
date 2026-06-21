---
description: Automatically intercepts, aggregates, and triages runtime crashes, error logs, and stack traces.
agent: debugging_specialist
subtask: true
---
Initialize an automated forensic bug triage and failure analysis pipeline.

### Step 1: Inject Systemic Debugging Protocols

skill({ name: "debugging-standards" })

### Step 2: Safe Workspace Diagnostic Harvesting

Gather safe workspace metadata to identify tool versions, framework environments, and localized project log structures without checking system processes:

- **Local Project Runtimes:** !`[ -f package.json ] && echo "Node: $(node -v 2>&1 || echo 'N/A') | Bun: $(bun -v 2>&1 || echo 'N/A')" || [ -f pyproject.toml -o -f requirements.txt ] && echo "Python: $(python3 --version 2>&1 || echo 'N/A')" || [ -f Cargo.toml ] && echo "Rust: $(rustc --version 2>&1 || echo 'N/A')" || echo "Unknown Local Engine Profile."`
- **Discovered Project Log Files:** !`find . -maxdepth 2 -type f \( -name "*.log" -o -name "*error*" -o -name "*.npm*" \) -not -path '*/.*' -not -path '*/node_modules/*' -not -path '*/.next/*' | head -n 10 || echo "No local workspace log files detected."`
- **Recent Framework Build Exceptions:** !`[ -d .next ] && echo "Next.js Build Dir Present" || [ -d .nuxt ] && echo "Nuxt Build Dir Present" || echo "No explicit meta-framework cash targets."`

### Step 3: Forensic Triage Assignment

Evaluate the gathered terminal error telemetry against your target files and active conversation history.

The `debugging_specialist` subagent must populate the following output variables for the plan writer:

- **intent_scope** – a mapping with `target_files` (list of file paths) and `operation_types` (list of actions such as CREATE, MODIFY).
- **plan_blocks** – a list of objects, each containing:
  - `path` – file to modify/create
  - `operation` – CREATE / MODIFY / DELETE
  - `language` – language identifier for the code block
  - `code` – the full code payload (no truncation, no placeholders).

These variables will be consumed by the `plan-writing` skill to emit a structured diagnostic report.

Generate the output block cleanly matching the schema above.

### Step 4: Emit Structured Diagnostic Report

skill({ name: "plan-writing" })
