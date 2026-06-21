---
name: plan-schema
description: Returns the canonical Opencode plan markdown template.
mode: skill
temperature: 0.0
top_k: 1
top_p: 0.95
---

# Plan Schema

The skill emits the exact markdown block that all plan-related agents use:

```
---
target_file: [Exact Path]
operation: [CREATE | MODIFY | DELETE]
line_range: [Exact target line ranges, e.g., "1-45" or "Full"]
---
### Implementation Block

```[language_id]
[Absolute complete code block payload containing zero abbreviations or placeholders]
```
```

This template is the single source of truth for the plan format. It is invoked by:
- `plan-writing` skill (formats for chat display)
- `extract-plan.md` command (formats and writes to file)
