---
description: Run a deep, multi-tier security and structural efficiency audit on project packages.
agent: dependency_auditor
subtask: true
---
Execute a multi-level structural and security audit of this workspace's dependency ecosystem.

### Step 1: Initialize Rules

skill({ name: "dependency-rules" })

### Step 2: System Capability Capture

Run automated checks to gather raw metrics for analysis:

- **Project Configuration:** !`[ -f package.json ] && cat package.json || [ -f pyproject.toml ] && cat pyproject.toml || echo "No standard manifest found."`
- **Active Outdated Version Logs:** !`if command -v pnpm >/dev/null 2>&1; then pnpm outdated; else npm outdated; fi 2>/dev/null || pip list --outdated 2>/dev/null || echo "No outdated tool responses"`
- **Active Structural Audit Logs:** !`if command -v pnpm >/dev/null 2>&1; then pnpm audit; else npm audit; fi 2>/dev/null || pip-audit 2>/dev/null || echo "No vulnerability engine response"`
- **Dead Import Tracking Check:** !`npx depcheck --json 2>/dev/null || echo "Depcheck execution skipped or unavailable"`

### Step 3: Analysis Assignment

Process all data points captured above. Generate a comprehensive, highly technical audit report matching this structural layout:

# Multi-Level Dependency Audit Report

## 1. 🚨 Security & Vulnerability Analysis

*Provide a table mapping package risks:*
| Package | Status | Detected Hazard / CVE | Required Safe Version |

## 2. 📉 Deprecation & Status Alerts

*List packages marked as deprecated, revoked, or structurally abandoned:*
- **Package Name:** [Reason for warning + migration recommendation]

## 3. 🔍 Dead Weight (Unused Dependencies)

*List modules explicitly declared in configuration files but never imported across the source code:*
- `[package-name]` -> [Mark if safe to remove instantly via clean commands]

## 4. ⚡ Bloat Optimization & Efficiency Blueprints

*Analyze the dependency chain weight. Identify redundant or bloated utility bundles and suggest cleaner alternatives to minimize disk space and optimize execution speeds:*
- **Current Setup:** [e.g., `moment` + `lodash` bundle footprint]
  - **Proposed Alternative:** [e.g., Swap for native ES6 tools and global Intl structures]
  - **Architectural Benefits:** [e.g., Reduces total disk footprint, minimizes bundle size, and lowers memory overhead]

## 5. 🛠️ Consolidated Remediation Workflow

Provide the precise command sequences needed to clean up the workspace (e.g., `pnpm remove ...` or `pnpm update ...`), respecting tool fallbacks.
