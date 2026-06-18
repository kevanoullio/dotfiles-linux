---
name: dependency-rules
description: System configuration map for deep architectural and security audits across package managers.
---
# Multilevel Audit Rules

When running a dependency audit, use your bash tools to discover ecosystem files and run verification scripts based on this priority tree:

### 1. Node.js Ecosystem Detection & Tool Fallback

Look for `package.json`. Determine the execution commands by evaluating package runner availability:

* **Check Command:** If `command -v pnpm >/dev/null 2>&1` passes, use **pnpm**. Otherwise, fall back to **npm**.
* **Security & Version Delta Commands:**
  * *pnpm Route:* `pnpm audit --json` and `pnpm outdated`
  * *npm Fallback:* `npm audit --json` and `npm outdated`
* **Unused Dependency Identification:** If a shell validation pass confirms `npx` access, run `npx depcheck --json` to locate dead imports.
* **Bloat Evaluation Parameters:** Identify heavy packages with cleaner modern drop-in replacements, for example:
  * Replace `moment` or `dayjs` -> Native JavaScript `Intl` or `Temporal` objects.
  * Replace `lodash` or `underscore` -> Modern ES6+ native array methodologies.
  * Replace `axios` -> Native global `fetch` streams where applicable.

### 2. Python Ecosystem Mapping

Look for `requirements.txt` or `pyproject.toml`:

* **Security Scan:** Execute `pip-audit --format json` or `safety check --json`.
* **Upgrade Delta:** Execute `pip list --outdated`.
* **Unused & Bloat Scan:** Check imports against the dependency matrix. Recommend consolidating fragmented utility libraries (e.g., swapping scattered request blocks for unified sessions).

### 3. Rust (Cargo)

* **Target Files:** `Cargo.toml`, `Cargo.lock`
* **Audit Commands:** `cargo audit`
* **Upgrade Analysis:** `cargo outdated`

## Multilevel Evaluation Criteria

Analyze the output using these five distinct architectural lenses:

1. **Security Status:** Cross-reference packages against active CVE lists; detail replacement targets.
2. **Deprecation/Revocation Status:** Flag packages explicitly abandoned by maintainers, marked deprecated on registries, or suffering from supply chain issues.
3. **Cross-Compatibility Stability:** Check if upgrading a package breaks engine constraints (e.g., `node` engines or `python_version` brackets).
4. **Dead Weight Detection:** Isolate packages that are listed in manifests but never imported in application files.
5. **Chain Consolidation:** Flag deep transitive dependency chains. Suggest alternatives that reduce disk size, minimize network overhead, and offer faster execution speeds.

## Version Upgrade Guardrails

When suggesting version bumps, apply these semantic limits:

* **Patch Bumps (`x.x.Y`):** Always safe to recommend.
* **Minor Bumps (`x.Y.0`):** Recommend if it mitigates a CVE, but note if API changes are possible.
* **Major Bumps (`Y.x.x`):** Explicitly mark as a breaking architectural shift.
