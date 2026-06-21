---
name: plan-writing
description: Formats extracted architectural decisions into the canonical Opencode plan markdown schema.
mode: skill
temperature: 0.0
top_k: 1
top_p: 0.95
---

# Plan Writing Skill

The skill receives structured output variables from the invoking agent, for example:

```yaml
intent_scope:
  target_files: ["src/auth.ts"]
  operation_types: ["CREATE"]
plan_blocks:
  - path: "src/auth.ts"
    operation: "CREATE"
    language: "typescript"
    code: |
      export const login = async (req, res) => { /*...*/ }
```

It emits a single markdown block by calling the plan-schema skill:

skill({ name: "plan-schema" })

No truncation, no placeholders, no comments – the output is a literal transcription of the supplied code.

**Usage inside an agent (YAML style)**

```yaml
output:
  intent_scope:
    target_files: ["src/auth.ts"]
    operation_types: ["CREATE"]
  plan_blocks:
    - path: "src/auth.ts"
      operation: "CREATE"
      language: "typescript"
      code: |
        export const login = async (req, res) => { /*...*/ }
skill({ name: "plan-writing" })
```

---

**Purpose**

- This skill formats a plan **for immediate display in the chat window**. It emits the exact markdown schema expected by downstream agents.
- The `@commands/extract-plan.md` command, on the other hand, parses the conversation history and writes the same formatted plan to a file in `.opencode/plans`. Both share the identical markdown structure, but they operate in different contexts (chat vs filesystem).
