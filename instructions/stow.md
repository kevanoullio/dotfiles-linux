# Managing Dotfiles with GNU Stow

GNU Stow is a symlink farm manager that makes it easy to manage your dotfiles by creating symbolic links from a central directory (like your dotfiles repo) to their target locations in your home directory.

## Basic Usage

1. **Install Stow**
   - On Arch: `sudo pacman -S stow`
   - On Ubuntu/Debian: `sudo apt install stow`
   - On Fedora: `sudo dnf install stow`

2. **Organize your dotfiles**
   - Place each application's config files in its own subdirectory inside your dotfiles repo. For example:
     ```
     dotfiles/
       bash/
         .bashrc
       nvim/
         .config/nvim/init.vim
     ```

3. **Stow a package**
   - From your dotfiles directory, run:
     ```
     stow bash
     stow nvim
     ```
   - This will symlink the files into your home directory.

4. **Unstow a package**
   - To remove the symlinks created by stow:
     ```
     stow -D bash
     ```

## Tips
- Always run `stow` from the root of your dotfiles directory.
- Use `stow -n` for a dry run to see what would be symlinked.
- For more details, see the [full guide](https://medium.com/quick-programming/managing-dotfiles-with-gnu-stow-9b04c155ebad).
