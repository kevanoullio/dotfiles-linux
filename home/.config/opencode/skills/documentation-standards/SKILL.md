---
name: documentation-standards
description: Formatting syntax guides for JSDoc, Python Docstrings, Rustdocs, and Javadoc.
---
# Multi-Language Documentation Blueprint Schema

When evaluating code signatures, map your analysis and generated outputs to these language-specific style guides:

### 1. TypeScript / JavaScript (JSDoc Style)

* **Format Block:** Standard Multi-line comments (`/** ... */`) immediately preceding the declaration block.
* **Core Meta Tags:** * `@param {type} name - Clear, descriptive definition of intent.`
  * `@returns {type} Explanation of return structures or fallback paths.`
  * `@throws {ErrorType} Conditions under which errors propagate.`

### 2. Python (PEP 257 / Sphinx or Google Style)

* **Format Block:** Triple double-quotes (`""" ... """`) placed as the very first line inside the module, class, or function execution block.
* **Core Structure (Google Layout Preferred):**

    ```python
    """Brief single-line summary of function purpose.

    Args:
        param_name (type): Clear description of variable intent.

    Returns:
        type: Explanation of return behaviors.

    Raises:
        ExceptionType: Conditions that cause termination.
    """
    ```

### 3. Rust (Rustdoc Style)

* **Format Block:** Outer line documentation tags (`///`) or module-level tags (`//!`).
* **Core Sections:** Standard markdown subsections. Ensure your proposals feature explicit `# Examples`, `# Errors` (if fallible), and `# Panics` (if code contains unwraps) headers.

### 4. Java (Javadoc Style)

* **Format Block:** Standard structured multi-line blocks (`/** ... */`).
* **Core Meta Tags:** Use explicit `@param`, `@return`, and `@throws` declarations matching native compilation schemas.
