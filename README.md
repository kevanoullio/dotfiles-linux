# dotfiles-linux

My user-specific configuration files to personalize my Linux experience.
All scripts use bash and are intended to be run on a Linux system.
Please see my Windows related dotfiles repository if you're interested.

## Branch Strategy

This repo uses a **common-core** branching model to keep configs in sync across
multiple Linux distributions while preserving per-distro files.

| Branch | Role |
|---|---|
| `main` | Common core — nvim config + generic scripts that work on any distro |
| `omarchy` | `main` + omarchy-specific theming (theme hot-reload, transparency), Hyprland, Waybar |
| `pop_os` | `main` + Pop!\_OS-specific script tweaks |

### Keeping branches in sync

Changes to the common core always start on `main`, then merge outward:

```bash
git checkout main
# ... edit common files (init.lua, lspconfig.lua, etc.) ...
git commit -m "..."

# Sync to distro branches:
git checkout pop_os && git merge main
git checkout omarchy && git merge main
```

Changes that are **distro-specific** (e.g. a new omarchy theme file) are committed
only on that branch and never merged back to `main`.

> **Why merge instead of cherry-pick?** `git merge main` brings all new common-core
> changes in one commit. Git remembers what's already been merged, so subsequent
> merges only bring the delta. Cherry-picking requires manually tracking each commit.

### Debugging branch alignment

Use these commands from the repo root to verify branch alignment:

```bash
# Show common files that differ between two branches
# (files that exist on both but have different content)
git diff <base>..<branch> -- <path> --diff-filter=M

# Show files that exist only on <branch> (additions, not on <base>)
git diff <base>..<branch> -- <path> --diff-filter=A

# Show full stat of everything that differs
git diff <base>..<branch> --stat -- <path>
```

**Example — check nvim alignment between main and omarchy:**

```bash
# Common files that accidentally diverged (should be empty):
git diff main..omarchy -- home/.config/nvim/ --diff-filter=M

# Files only on omarchy (expected additions):
git diff main..omarchy -- home/.config/nvim/ --diff-filter=A

# Full picture:
git diff main..omarchy --stat -- home/.config/nvim/
```

If `--diff-filter=M` shows unexpected files, fix them on `main` first, then
re-merge. If it's empty, the common core is in sync — only the expected
distro-specific additions remain.

### Common issues and fixes

| Symptom | Likely cause | Fix |
|---|---|---|
| `git merge main` produces conflicts in nvim files | Common files were edited independently on the distro branch | Resolve keeping `main`'s version (it's the canonical common core), then `git commit` |
| nvim configs silently drift apart | Cherry-picks were used instead of merges | Check with `git diff main..branch --diff-filter=M`; if non-empty, fix the drift and switch to `git merge main` going forward |
| `git merge main` brings unwanted distro-specific files into `main` | Someone merged the wrong direction | `git revert` the merge; always merge FROM main TO distro branches, never the reverse |
| New distro branch needed | A fresh Linux install | Branch from `main`, add distro-specific files, then `git merge main` periodically |

## Neovim Setup

This repo includes a full Neovim configuration based on **LazyVim** with extensive
language server protocol (LSP) support. The config is in `home/.config/nvim/`.

### Architecture

- **Plugin Manager**: [lazy.nvim](https://github.com/folke/lazy.nvim) — bootstraps
  automatically on first launch (no manual clone needed).
- **Distribution**: [LazyVim](https://github.com/LazyVim/LazyVim) — provides sensible
  defaults for keymaps, options, autocommands, and plugin configuration.
- **Completion**: [blink.cmp](https://github.com/Saghen/blink.cmp) — included with
  LazyVim; provides LSP-aware autocompletion out of the box.
- **Fuzzy Finder**: [fzf-lua](https://github.com/ibhagwan/fzf-lua) — default picker
  for files, grep, buffers, and more.
- **File Explorer**: [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim) —
  toggled via `<leader>e`.
- **Formatting**: [conform.nvim](https://github.com/stevearc/conform.nvim) — automatic
  formatting on save; configured per filetype.
- **Statusline**: [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) —
  included with LazyVim.
- **Dashboard**: [snacks.nvim](https://github.com/folke/snacks.nvim) — startup
  dashboard with custom ASCII art header.
- **Theme**: [monokai-pro](https://github.com/gthelding/monokai-pro.nvim) — active
  colorscheme, with 14 additional themes available for hot-reloading.

### LSP Support by Language

LazyVim language extras handle LSP server installation, diagnostics, and code actions
for the following languages. Servers are auto-installed via
[Mason](https://github.com/williamboman/mason.nvim):

| Language | Extra |
|---|---|
| TypeScript / JavaScript | `lang.typescript` |
| Python | `lang.python` |
| Rust | `lang.rust` |
| Go | `lang.go` |
| Java | `lang.java` |
| Kotlin | `lang.kotlin` |
| C / C++ | `lang.clangd` |
| C# (.NET) | `lang.dotnet` |
| Dart / Flutter | `lang.dart` |
| Zig | `lang.zig` |
| Astro | `lang.astro` |
| Tailwind CSS | `lang.tailwind` |
| JSON / JSONC | `lang.json` |
| YAML | `lang.yaml` |
| TOML | `lang.toml` |
| Markdown | `lang.markdown` |
| Docker / Dockerfile | `lang.docker` |
| Git commit / rebase | `lang.git` |
| SQL | `lang.sql` |
| Julia | `lang.julia` |
| R | `lang.r` |
| CMake | `lang.cmake` |

Additionally, `lua/plugins/lspconfig.lua` explicitly enables `ts_ls`, `html`, and
`lua_ls` servers, while `lua/plugins/lsp-langs.lua` adds Odin (`olingo`) and Astro
(with local `astro-ls`) servers plus extra treesitter parsers.

### File Structure

```
home/.config/nvim/
├── init.lua              # Entry point; sets leader, loads config
├── lazyvim.json           # LazyVim extras (neo-tree)
└── lua/
    ├── ascii-art-night-sky.txt  # Custom dashboard header art
    ├── config/
    │   ├── lazy.lua       # Bootstraps lazy.nvim; loads LazyVim + extras
    │   ├── options.lua     # User option overrides
    │   ├── keymappings.lua # Additional custom keymaps
    │   └── autocmds.lua    # Custom autocommands
    └── plugins/
        ├── lspconfig.lua         # LSP server configs (opts.servers pattern)
        ├── dashboard.lua         # Snacks dashboard with ASCII art
        ├── editorconfig.lua      # EditorConfig support
        ├── vim-tmux-navigation.lua  # Ctrl+hlkj tmux pane navigation
        └── ... (distro-specific plugin files — varies by branch)
```

> Each branch may include additional distro-specific plugin files (e.g. theme
> configs, transparency settings). They inherit the common core above. Run
> `git diff main..<branch> -- home/.config/nvim/ --diff-filter=A` to see
> what's unique to a given branch.

### Custom Keymaps

| Keymap | Action |
|---|---|
| `<C-p>` | Find Files (fzf-lua) |
| `<leader>lg` | Live Grep (fzf-lua) |
| `<leader>gf` | Format buffer |
| `<leader>?` | Show which-key (normal/visual) |
| `<C-?>` | Show which-key (insert) |
| `<C-h/j/k/l>` | Tmux pane navigation |
| `<leader>e` | Toggle neo-tree file explorer |

All standard LazyVim keymaps also apply. See the
[LazyVim docs](https://www.lazyvim.org/configuration/keymaps) for the full list.

### Installing to a New System

There are two ways to deploy this configuration:

#### Option 1: Full dotfiles setup (recommended)

Run the full setup script which handles Neovim dependencies and copies all config
files:

```bash
bash scripts/cli_tools/setup_nvim.sh
```

Or as part of the complete environment setup:

```bash
bash scripts/main_full_setup.sh
```

#### Option 2: Manual copy

```bash
# Install Neovim and dependencies
sudo apt install neovim ripgrep unzip npm

# Copy config
cp -r home/.config/nvim ~/.config/nvim

# Launch Neovim — lazy.nvim and all plugins install automatically
nvim
```

> **Note**: lazy.nvim bootstraps itself on first launch. No manual clone is needed.
> Existing config files are never overwritten without prompting.
