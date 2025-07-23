# dots

Personal shell configuration for zsh and CLI tools.

## Installation

```bash
./install.zsh
```

This will:
- Initialize and update git submodules
- Create symlinks for configuration files
- Automatically reload the shell

## Structure

- `dots/` - Core dotfiles (`~/.zshrc`, `~/.tmux.conf` etc)
- `config/` - xdg style config directory files (`~/.config/`)
  - `zsh/` - zsh configuration modules
  - `tmux/` - tmux configuration
- `custom/` - custom scripts and local overrides

## Tools

- `dots` or `...` is a utility to manage the project
  - `dots reload` - reloads the config. Aliased to `.r`
  - `dots doctor` - some simple health checks. Aliased to `.d`
  - `dots update` - get the latest config. Aliased to `.u`
