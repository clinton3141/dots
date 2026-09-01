# dots

Personal shell configuration for zsh and CLI tools.

## Installation

### Standard Installation

```bash
./install.zsh
```

This will:
- Create symlinks for configuration files
- Install the tmux plugins pinned in `dots/dots.lock`
- Restore the agent skills listed in `config/agents/skill-lock.json`
- Enable `chat.useClaudeMdFile` in your VS Code user settings
- Automatically reload the shell

Anything it cannot do unattended - a target that already exists and is not a
symlink, a missing dependency - is listed in a summary at the end, and the
script exits non-zero.

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
2. **Decide**:
   - Like it? → `dots cement` (completes trial, removes backup, keeps new config)
   - Don't like it? → `dots uninstall` (restores your original setup)

## Structure

- `dots/` - Core dotfiles (`~/.zshrc`, `~/.tmux.conf` etc)
- `config/` - xdg style config directory files (`~/.config/`)
  - `zsh/` - zsh configuration modules
  - `tmux/` - tmux configuration
  - `zsh-abbr/` - abbreviation database
  - `agents/` - shared coding agent config: working agreements and skills
    (linked into `~/.claude/`, `~/.copilot/` and `~/.agents/`)
  - `claude/` - Claude Code specific config (`~/.claude/`)
- `custom/` - custom scripts and local overrides
- `lib/` - installer internals shared by `install.zsh` and `dots`
  - `link.zsh` - the symlink map, used by install, `dots link` and `dots doctor`

## Tools

- `dots` or `...` is a utility to manage the project
  - `dots reload` - reloads the config. Aliased to `.r`
  - `dots doctor` - some simple health checks. Aliased to `.d`
  - `dots link` - create any symlinks that are missing, and repair broken ones. Aliased to `.l`
  - `dots update` - get the latest config, then link it. Aliased to `.u`
  - `dots cement` - complete trial and commit to dotfiles (make installation permanent)
  - `dots uninstall` - uninstall dotfiles and restore original setup (trial mode only)
