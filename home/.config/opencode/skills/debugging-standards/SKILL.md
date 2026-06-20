# 🩺 Universal Systems Debugging & Forensic Standards

When triaging runtime failures, system panics, or logical anomalies, you must strictly process the diagnostics using this forensic software engineering framework.

## 1. 🔍 Forensic Stack Trace Isolation

- **Identify the Origin:** Trace the error precisely to its source file, class, function, and absolute line number. Do not analyze surrounding files until the exact line of execution failure is isolated.
- **Determine the Failure Category:** Classify the panic (e.g., Null Pointer Reference, Out of Memory, Type Coercion, Race Condition, Unhandled Promise Rejection).
- **Isolate the State Vector:** Identify what local, global, or environment variable data payloads entered the execution path immediately prior to the crash.

## 2. ⚡ Concurrency, State, and Mutation Analysis

- **Asynchronous State Drifts:** Check for un-awaited promises, race conditions between concurrent worker threads, or stale state closures.
- **Side-Effect Interception:** Evaluate whether an external database connection drop, unhandled network API timeout, or local disk I/O permission denial cascadingly triggered the failure.

## 3. 🛡️ Safe Remediation & Regression Testing

- **Root-Cause Target Fixes:** Design a patch that addresses the underlying engineering vulnerability, not just the symptom (e.g., don't just wrap a failing line in a blank try/catch block; fix the underlying state anomaly).
- **Side-Effect Evaluation:** Analyze whether the proposed patch introduces breaking mutations or performance regressions to adjacent modules.
- **Validation Strategy:** Define the exact execution parameters or test assertions required to confirm the bug is completely eradicated.
