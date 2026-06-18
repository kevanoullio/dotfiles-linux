---
description: Run an on-demand static application security (SAST) sweep across the codebase context.
agent: security_auditor
subtask: true
---
Initialize a high-priority application security audit pass for this repository workspace.

### Step 1: Initialize Threat Vectors

skill({ name: "security-rules" })

### Step 2: Automated Secret & Injection Sweeps

Run targeted terminal strings to uncover high-priority vulnerabilities instantly:

- **Hardcoded Secret Hunting:** !`grep -rnE "(password|secret|token|api_key|private_key)\s*=\s*['\"][a-zA-Z0-9_\-]+['\"]" . --exclude-dir={node_modules,.git,dist,build} || echo "No obvious hardcoded assignment strings found."`
- **Raw SQL Injection Sweeps:** !`grep -rnI "SELECT.*FROM.*+\|INSERT.*VALUES.*+" . --exclude-dir={node_modules,.git,dist,build} || echo "No raw string concatenation database sweeps found."`
- **Dangerous Eval Injections:** !`grep -rnE "(\beval\(|\bexec\()" . --exclude-dir={node_modules,.git,dist,build} || echo "No dynamic execution blocks detected."`

### Step 3: Analysis Assignment

Process all discovered configurations, file permissions, and data entry flows. Generate a unified security analysis matching this structure:

# 🛡️ Application Security Audit Report (SAST Summary)

## 1. 🔥 Critical Injection Risks & Input Flaws

*Detail any unvalidated data conduits discovered in the application lines:*
- **Target Vulnerability:** [e.g., Unparameterized SQL Execution / Command Injection]
  - **Location:** `[File Path] : Line [X]`
  - **Threat Profile:** [Explain exactly how a malicious input payload could exploit this path]
  - **Remediation:** [Provide the exact secure, sanitized, or parameterized code update required]

## 2. 🔐 Broken Access Control & Endpoint Vulnerabilities

*List endpoints or routes missing middleware checks or authorization gates:*
- **Route Definition:** [File Path and code block]
  - **Flaw:** [e.g., Missing route verification middleware, exposed sensitive properties]

## 3. 🔑 Token, Secret, and Cryptographic Failures

*Flag weak encryption hashes or hardcoded application parameters:*
- **Line Target:** [File Path and line]
  - **Finding:** [e.g., Hardcoded webhook secret token or usage of deprecated hashing tools]

## 4. 📝 Actionable Hardening Checklist

Provide a concise, direct summary list of file patches required to fully eliminate these risks, formatted cleanly for immediate transition to your implementation plans.
