# dotfiles-linux

My user-specific configuration files to personalize my Linux experience.
All scripts use bash and are intended to be run on a Linux system.
Please see my Windows related dotfiles repository if you're interested.

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
  dashboard included with LazyVim.

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
`lua_ls` servers.

### File Structure

```
home/.config/nvim/
├── init.lua              # Entry point; sets leader, loads config
├── lazyvim.json           # LazyVim extras (neo-tree)
└── lua/
    ├── ascii-art-night-sky.txt  # Preserved ASCII art for potential use
    ├── config/
    │   ├── lazy.lua       # Bootstraps lazy.nvim; loads LazyVim + extras
    │   ├── options.lua     # User option overrides on top of LazyVim defaults
    │   └── keymappings.lua # Additional custom keymaps
    └── plugins/
        ├── lspconfig.lua           # LSP server configs (opts.servers pattern)
        ├── editorconfig.lua        # EditorConfig support
        ├── gruvbox.lua             # Gruvbox colorscheme
        └── vim-tmux-navigation.lua # Ctrl+hlkj tmux pane navigation
```

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
