---
description: Compiles the conversation's final architecture notes into a local plan file.
model: local-swap/gpt-oss:20b
---
Review our entire conversation history above. Extract the finalized engineering plan and write it cleanly as a unified, unambiguous, step-by-step technical plan.

Format the output strictly with these target blocks:

- **Target File**: [Exact Path]
- **Operation**: [CREATE | MODIFY | DELETE]
- **Line Range**: [Exact target line ranges]
- **Exact Code Payload**:

```text
[Exact code block with zero abbreviations or placeholders]
```

Save this content directly into the local workspace directory under `.opencode/plans/` as a .md file with an appropriate name. Do not modify any other file.
