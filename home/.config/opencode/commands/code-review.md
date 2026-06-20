---
description: Executes a rigorous, line-by-line security, performance, and architectural code review.
agent: code_reviewer
subtask: true
---
Initialize a comprehensive code quality, safety, and architectural compliance audit pipeline.

### Step 1: Inject Code Review Standards

skill({ name: "code-review-standards" })

### Step 2: Live Repository Context Capture

Gather active workspace diffs, uncommitted modifications, and branch health matrices to focus the code review boundary:

- **Modified Files Workspace Status:** !`git status -s || echo "Not a git repository or no files currently modified."`
- **Staged Code Changes (Cached Diffs):** !`git diff --cached || git diff HEAD || echo "No active file diffs found in workspace."`
- **Recent Commit Line Delta:** !`git diff HEAD~1 --stat 2>/dev/null || echo "No prior local commits found to diff against."`

### Step 3: Deep Review Assignment

Analyze the captured file modifications and conversation history against enterprise-grade software engineering benchmarks.

Instruct your subagent process to systematically inspect the files for logical defects, race conditions, edge-case failures, optimization bottlenecks, and style deviations. The output must reference exact line numbers and provide actionable refactoring examples.

Generate the output block cleanly matching the schema below:

# 🔍 Code Review Execution Report

## 1. 📈 Executive Summary & Code Health Score

*Provide a high-level summary of code quality and an objective health score (e.g., 8.5/10).*

## 2. 🚨 Critical Defects & Security Vulnerabilities

*List any breaking bugs, security issues, resource leaks, or race conditions:*

- **File:** `path/to/file.ext` (Lines X-Y)
  - **Issue:** [Description of problem]
  - **Fix:** [Actionable solution]

## 3. 🛠️ Code Smells, Readability & Maintainability

*Identify architectural anti-patterns, poor naming, redundant logic, or documentation drift:*

- [List specific improvement opportunities with file and line references]

## 4. 💡 Proposed Refactored Alternatives

Provide optimized implementation examples for the critical blocks flagged above. Do not truncate the target functions.
