---
name: readme-standards
description: Blueprint structures and mandatory sections for project READMEs categorized by tech stack.
---
# Global README Architecture Rules

Every generated or updated `README.md` must feature a clean markdown hierarchy, consistent formatting, and contain the following specialized sections based on project topology:

### 1. Web Development Layouts (Node.js/Next.js/Vite/etc.)

* **Header:** Project Name, clear single-sentence value proposition, and prerequisite engine baselines (e.g., Node version).
* **Environment Configuration:** Explicitly document all `.env.example` keys, what they do, and where to obtain them.
* **Development Workflow:** Step-by-step commands using the exact repository lockfile tool (`pnpm dev`, `npm run build`, etc.).

### 2. Standalone Application & Native Binaries (Rust/Go/C++)

* **Compilation Requirements:** List system-level toolchains, compilers, and dependencies required to build from source.
* **Build Pipeline:** Commands to generate optimized release profiles (e.g., `cargo build --release`).
* **Distribution Matrix:** Explicitly document where compiled target binaries are placed on disk and how to run them directly from the terminal interface.

### 3. Virtual Environment Ecosystems (Python/Poetry/Venv)

* **Isolation Setup:** Instructions on setting up and initializing the virtual environment framework (e.g., `python -m venv .venv && source .venv/bin/activate`).
* **Dependency Installation:** Explicit lockfile commands (`pip install -r requirements.txt` or `poetry install`).

### 4. Mandatory Global Footprint (Required for ALL Project Types)

* **Repository Folder Tree:** A clean text-based visualization of primary top-level folders and entry points (excluding build artifacts and lockfiles).
* **Testing Protocol:** Explicit instructions outlining how to execute local test runners and verification suites.
