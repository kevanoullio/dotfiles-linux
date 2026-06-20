---
description: Automatically intercepts, aggregates, and triages runtime crashes, error logs, and stack traces.
agent: debugging_specialist
subtask: true
---
Initialize an automated forensic bug triage and failure analysis pipeline.

### Step 1: Inject Systemic Debugging Protocols

skill({ name: "debugging-standards" })

### Step 2: Live Environment Diagnostic Harvesting

Execute local terminal sweeps to collect active runtime exceptions, log dumps, and error contexts around the workspace:

- **Recent Application Log Traces:** !`[ -f error.log ] && tail -n 50 error.log || [ -f combined.log ] && tail -n 50 combined.log || echo "No standard log files detected in root directory."`
- **Active System Process Health:** !`ps aux | grep -E "(node|python|bun|cargo|go)" | grep -v grep | head -n 10 || echo "No primary runtime engines active."`
- **Compiler/Runtime Panic Check:** !`git status -s | grep -E "crash|dump|log" || echo "No immediate external crash dumps located."`

### Step 3: Forensic Triage Assignment

Evaluate the gathered terminal error telemetry against your target files and active conversation history.

Instruct your subagent process to mentally trace the logical pathways that triggered this system failure. The subagent must deliver a surgical breakdown detailing the true root cause, the exact files and lines involved, and an absolute zero-deviation patch to fix it.

Generate the output block cleanly matching the schema below:

# 🩺 Root Cause Analysis & Diagnostic Report

## 1. 🚨 The Crime Scene (Failure Classification)

- **Error Signature:** [e.g., TypeError: Cannot read properties of undefined (reading 'split')]
- **Failure Origin:** `path/to/target_file.ext` (Line X)
- **Impact Radius:** [e.g., Blocks user authentication route completely]

## 2. 🕵️ Forensic Investigation (Root Cause Analysis)

*Explain exactly why this failed under the hood. Trace the memory, state changes, or logic gates that broke down:*

- [Provide a deep, logical explanation of the execution flow right before the crash]

## 3. 🩹 The Surgical Patch (Actionable Remediation)

Provide the exact, complete code block modification required to permanently fix the bug. Do not truncate.

```[language_id]
[Insert complete corrected function or code block payload here]
```
