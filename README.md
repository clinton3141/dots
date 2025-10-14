# dots

Personal shell configuration for zsh and CLI tools.

## Installation

### Standard Installation

```bash
./install.zsh
```

This will:
- Initialize and update git submodules
- Create symlinks for configuration files
- Automatically reload the shell

### Trial Mode Installation (Recommended for First Time)

Try the dotfiles safely with the ability to fully uninstall:

```bash
./install.zsh --trial
```

This will:
- Back up your existing dotfiles to `~/.config/dots/backup-{timestamp}/`
- Create a trial lock file tracking what was backed up
- Install the dotfiles as normal
- Allow you to easily restore your original setup or make the installation permanent

**After trying the dotfiles:**

- **If you like them:** Make the installation permanent
  ```bash
  dots cement
  ```

- **If you want to go back:** Restore your original dotfiles
  ```bash
  dots uninstall
  ```

Trial mode allows you to safely test these dotfiles without permanently changing your system.

### How it works:

1. **Install with `--trial` flag**: Your existing dotfiles are backed up
2. **Try it out**: Use the configuration normally
3. **Decide**:
   - Like it? → `dots cement` (completes trial, removes backup, keeps new config)
   - Don't like it? → `dots uninstall` (restores your original setup)

## Structure

- `dots/` - Core dotfiles (`~/.zshrc`, `~/.tmux.conf` etc)
- `config/` - xdg style config directory files (`~/.config/`)
  - `zsh/` - zsh configuration modules
  - `tmux/` - tmux configuration
  - `zsh-abbr/` - abbreviation database
- `custom/` - custom scripts and local overrides

## Tools

- `dots` or `...` is a utility to manage the project
  - `dots reload` - reloads the config. Aliased to `.r`
  - `dots doctor` - some simple health checks. Aliased to `.d`
  - `dots update` - get the latest config. Aliased to `.u`
  - `dots cement` - complete trial and commit to dotfiles (make installation permanent)
  - `dots uninstall` - uninstall dotfiles and restore original setup (trial mode only)
