---
name: security-rules
description: Core vulnerability heuristics covering input validation, access management, and secure coding practices.
---
# AppSec Vulnerability Heuristics

When scanning the repository workspace, evaluate the application layers against these critical security risk vectors:

### 1. Input Handling & Injection Vectors

* **SQL Injection:** Flag raw string interpolations inside database execution strings (e.g., `` `SELECT * FROM users WHERE id = ${input}` `` instead of parameterized tokens).
* **Command Injection:** Flag any user-provided strings passed unescaped into execution utilities like `exec`, `spawn`, `system`, or `eval`.
* **XSS / Rendering Risks:** Identify places where inputs are unsafely forced into UI layouts (e.g., `dangerouslySetInnerHTML` in React or unescaped templates in backend rendering engines).

### 2. Access Controls & Middleware Integrity

* **Unprotected Routes:** Cross-examine API route definition files. Flag endpoints that are missing explicit verification/session validation middleware blocks.
* **Privilege Escalation:** Verify that resource updates check ownership boundaries (e.g., validating that user A cannot update user B's profile simply by changing an `id` query parameter).

### 3. Cryptography & Secret Hygiene

* **Secret Leaks:** Actively hunt for hardcoded API tokens, JWT secret strings, private keys, or passwords.
* **Weak Crypto:** Flag outdated or broken hashing algorithms (e.g., `md5`, `sha1`) used for passwords or sensitive integrity checks.
