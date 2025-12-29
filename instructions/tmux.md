## tmux Plugin Manager (TPM)

[TPM (tmux Plugin Manager)](https://github.com/tmux-plugins/tpm) is the recommended way to manage tmux plugins. It allows you to easily install, update, and remove plugins that extend tmux's functionality.


### Installing TPM (tmux Plugin Manager)

You can install TPM (tmux Plugin Manager) in one of two ways:

**1. Using a package manager (if available):**

For Arch Linux (AUR):
```sh
yay -S tmux-plugin-manager
```
For other distributions, check your package manager or use the manual method below.


**2. Manual installation (works everywhere):**

To install TPM manually, simply clone the TPM repository:
```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```
No further steps are required—cloning the repo completes the installation. After this, restart tmux and press `prefix + I` to install plugins listed in your `.tmux.conf`.


## Saving and Restoring tmux Sessions

### Automatic (Recommended)

Install these plugins (managed by TPM):

- [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect): Save and restore tmux sessions (prefix + Ctrl-s to save, prefix + Ctrl-r to restore)
- [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum): Automatic periodic saving and restore on tmux start
- [tmux-sessionx](https://github.com/omerxx/tmux-sessionx): Extra session management features (optional)

**Install via TPM:**
1. Add the following lines to your `.tmux.conf` (already present in this repo):
	 ```
	 set -g @plugin 'tmux-plugins/tpm'
	 set -g @plugin 'tmux-plugins/tmux-resurrect'
	 set -g @plugin 'tmux-plugins/tmux-continuum'
	 set -g @plugin 'omerxx/tmux-sessionx'
	 run '~/.tmux/plugins/tpm/tpm'
	 ```
2. Start tmux and press `prefix` + `I` to install plugins.
3. Use `prefix` + `Ctrl-s` to save, `prefix` + `Ctrl-r` to restore.

### Manual Installation

Clone the plugin repos manually if you don't use TPM:

- [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect):
	`git clone https://github.com/tmux-plugins/tmux-resurrect ~/.tmux/plugins/tmux-resurrect`
- [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum):
	`git clone https://github.com/tmux-plugins/tmux-continuum ~/.tmux/plugins/tmux-continuum`
- [tmux-sessionx](https://github.com/omerxx/tmux-sessionx) (optional):
	`git clone https://github.com/omerxx/tmux-sessionx ~/.tmux/plugins/tmux-sessionx`

Add the same plugin lines to your `.tmux.conf` as above.

**Usage:**
- Save session: `prefix` + `Ctrl-s`
- Restore session: `prefix` + `Ctrl-r`

See each plugin's README for advanced options.
