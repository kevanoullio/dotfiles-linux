---
description: Automatically generate or synchronize the repository README based on current system state.
agent: documentation_specialist
subtask: true
---
Initialize a comprehensive README audit and update pipeline for this workspace.

### Step 1: Inject Structural Templates

skill({ name: "readme-standards" })

### Step 2: Live Repository Context Capture

Gather live ecosystem properties directly from the workspace root to verify the current configuration state:

- **Project Structure Tree:** !`find . -maxdepth 2 -not -path '*/.*' -not -path './node_modules' -not -path './dist' -not -path './build' -not -path './.venv' | sort | sed 's|[^/]*/|- |g' | head -n 40`
- **Active Environment Keys:** !`[ -f .env.example ] && cat .env.example || [ -f .env ] && grep -E '^[A-Z0-9_]+=' .env | sed 's/=.*$/=your_value_here/' || echo "No explicit environment templates found."`
- **Core Build Directives:** !`[ -f package.json ] && head -n 25 package.json || [ -f Cargo.toml ] && head -n 25 Cargo.toml || [ -f pyproject.toml ] && head -n 25 pyproject.toml || echo "No project configuration file found."`
- **Existing README State:** !`[ -f README.md ] && head -n 50 README.md || echo "No initial README.md found in workspace root."`

### Step 3: Analysis Assignment

Compare your captured project structural data points against our current conversation state and recent features.

Instruct your subagent process to synthesize this context into a complete, pristine, standalone markdown payload. If a `README.md` already exists, perform an intelligent merge—preserving custom business prose while cleanly updating dependency versions, missing script tags, environment keys, and directory structures.

Generate the output block cleanly matching the schema below:

# 📝 README Synchronization Execution Blueprint

## 1. 🔍 Structural Adjustments Log

*Identify what changed or what was missing in the project documentation:*
- [e.g., Added new section for `.env` variables; recalculated the directory tree diagram; updated build commands from npm to pnpm]

## 2. 📄 Complete Final README Markdown Payload

Provide the complete, updated text for the final document below. Ensure it matches your structural requirements exactly so that it can be extracted cleanly to disk:

```markdown
[Insert the absolute complete, raw markdown text for the updated README.md here. Do not truncate, use ellipses, or leave placeholder comments.]
```
