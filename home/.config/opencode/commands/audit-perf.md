---
description: Run a deep static performance analysis on target codebases to identify latency and memory blocks.
agent: performance_auditor
subtask: true
---
Initialize a thorough performance evaluation pass for this workspace.

### Step 1: Initialize Analysis Metrics

skill({ name: "performance-rules" })

### Step 2: Automated Structural Discovery

Use discovery tools to scan for obvious hot-spots in the current scope:

- **Heavy Patterns Scan:** !`grep -rnE "(forEach.*forEach|for.*for|while.*while)" . --exclude-dir={node_modules,.git,dist,build} || echo "No nested loops found via grep."`
- **Database Query Sweeps:** !`grep -rnE "(select|find|where|query|db\.)" . --exclude-dir={node_modules,.git,dist,build} || echo "No database call signatures found."`

### Step 3: Analysis Assignment

Compile all discovered loops, file structures, and algorithms into a comprehensive technical review matching this layout:

# ⚡ Performance & Optimization Audit Report

## 1. 📉 Algorithmic Inefficiencies & Complexity Blocks

*Identify specific lines where execution scaling is poorly managed:*
- **Location:** `[File Path] : Line [X]`
  - **Detected Trap:** [e.g., $O(N^2)$ array search loop]
  - **Remediation Blueprint:** [How to swap for a Map structure, cache the result, or optimize the loop]

## 2. 🗄️ Database & Data Layer Bottlenecks

*Highlight missing data boundaries or query traps:*
- **Query Path:** [Code file and query line]
  - **Risk:** [e.g., Imminent $N+1$ loop or unpaged massive collection fetch]
  - **Fix:** [Provide specific syntax example showing optimized joins or explicit fetching boundaries]

## 3. 📦 Asset Size & Memory Allocation Profiling

*Identify memory leaks, garbage collection pressure, or bundle bloat:*
- **Source File:** [Target path]
  - **Issue:** [e.g., Heavy redundant object mapping inside high-frequency loops]

## 4. 🚀 Execution Speed Optimization Summary

Provide the exact revised, high-performance code payload blocks ready for the down-stream blueprint file, proving exactly why the new approach reduces operational complexity.
