---
description: Automatically audit, refresh, or generate language-compliant documentation tags for code files.
agent: documentation_specialist
subtask: true
---
Initialize a multi-tier documentation audit pass for the target code module.

### Step 1: Inject Style Standards

skill({ name: "documentation-standards" })

### Step 2: Context Evaluation

Analyze our recent architecture targets along with the active file footprint provided below:

- **Target File Path:** "$ARGUMENTS"
- **Raw File Source:** !`[ -f "$ARGUMENTS" ] && cat "$ARGUMENTS" || echo "Please specify a target file path as an argument to the command (e.g., /update_docs src/index.ts)"`

### Step 3: Analysis Assignment

Compare the current raw file source code parameters, return signatures, and class variables against existing blocks. Identify:

1. Missing documentation definitions for export paths, interfaces, and public functions.
2. Stale or outdated descriptors (variables that were deleted, renamed, or modified in the code but remain in the comments).
3. Violations of native language code formatting guidelines.

Generate a comprehensive implementation blueprint mapping out the required changes:

# 📝 Documentation Synchronization Report

## 1. 🔍 Stale & Mismatched Documentation Deltas

*List comments that no longer match the true signature of the code:*

- **Location:** `[Line Range / Function Signature]`
  - **Mismatch Issue:** [e.g., Missing `@param` for newly added config property; outdated return descriptor]

## 2. ➕ Missing Documentation Blocks

*Identify methods or modules missing standard ecosystem comment structures:*

- **Signature Target:** `[Method/Class Name]`
  - **Standard Required:** [e.g., Missing Google-style Python docstring wrapper]

## 3. 🛠️ Exact Code Docstring Injection Blueprint

Provide the exact code modification patches. Ensure you display the immediate surrounding function signature lines so that the downstream `build` agent can copy and merge the changes cleanly without altering execution logic:

```text
[Insert exact raw code blocks with corrected documentation tags here]
```
