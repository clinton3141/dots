#!/usr/bin/env zsh

set -e

DOTFILES_DIR="${0:A:h}"

source "$DOTFILES_DIR/dots/dots.lock"

check_target() {
    local target="$1"
    local expected_source="$2"

    if [[ -e "$target" ]]; then
        if [[ -L "$target" ]]; then
            local current_source="$(readlink "$target")"
            if [[ "$current_source" == "$expected_source" ]]; then
                return 0
            else
                return 2
            fi
        else
            return 2
        fi
    fi
    return 1
}

create_symlink() {
    local source="$1"
    local target="$2"

    local result
    check_target "$target" "$source"
    result=$?

    if [[ $result == 0 ]]; then
        echo "✅ $target is correctly linked"
    elif [[ $result == 1 ]]; then
        echo "🔗 Creating $target"
        command ln -s "$source" "$target"
        echo "✅ $target created successfully"
    elif [[ $result == 2 ]]; then
        echo "⚠️  $target exists but is not a symlink"
    fi
}

main() {
    echo "📋 checking prerequisites"
    if ! command -v zsh >/dev/null 2>&1; then
        echo "❌ FATAL ERROR: zsh is not installed on this system"
        exit 1
    fi
    echo "✅ zsh is installed"

    if [[ ! -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]]; then
        echo "🔌 zinit is required for zsh plugin management and performance optimization"
        echo ""
        read -q "?❓ Would you like to install zinit now? (y/n): "
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "📦 Installing zinit plugin manager..."
            command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
            command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
                echo "✅ zinit installed successfully" || \
                (echo "❌ zinit installation failed" && exit 1)
        else
            echo "❌ FATAL ERROR: zinit is required."
            exit 1
        fi
    else
        echo "✅ zinit is installed"
    fi

    echo ""

    echo "🚀 Starting dotfiles installation"

    if command -v tmux >/dev/null 2>&1; then
        echo "✅ tmux is installed"

        echo "📦 Installing tmux plugins"

        if [[ ! -d "$DOTFILES_DIR/config/tmux/plugins/tmux-sensible" ]]; then
            echo "📦 Installing tmux-sensible"
            command git clone https://github.com/tmux-plugins/tmux-sensible "$DOTFILES_DIR/config/tmux/plugins/tmux-sensible"
        else
            echo "✅ tmux-sensible is already installed"
        fi
        command git -C "$DOTFILES_DIR/config/tmux/plugins/tmux-sensible" fetch
        command git -C "$DOTFILES_DIR/config/tmux/plugins/tmux-sensible" checkout "$DOTS_TMUX_SENSIBLE_HASH"
        echo "✅ tmux-sensible pinned to hash $DOTS_TMUX_SENSIBLE_HASH"

        # Install monokai-pro.tmux
        if [[ ! -d "$DOTFILES_DIR/config/tmux/plugins/monokai-pro.tmux" ]]; then
            echo "📦 Installing monokai-pro.tmux"
            command git clone https://github.com/loctvl842/monokai-pro.tmux "$DOTFILES_DIR/config/tmux/plugins/monokai-pro.tmux"
        else
            echo "✅ monokai-pro.tmux is already installed"
        fi
        command git -C "$DOTFILES_DIR/config/tmux/plugins/monokai-pro.tmux" fetch
        command git -C "$DOTFILES_DIR/config/tmux/plugins/monokai-pro.tmux" checkout "$DOTS_MONOKAI_PRO_HASH"
        echo "✅ monokai-pro.tmux pinned to hash $DOTS_MONOKAI_PRO_HASH"
    else
        echo "⚠️  tmux is not installed - skipping tmux configuration"
    fi

    if [[ ! -d "$HOME/.config" ]]; then
        echo "📁 Creating ~/.config directory"
        command mkdir -p "$HOME/.config"
        echo "✅ Created ~/.config directory"
    else
        echo "📁 ~/.config directory already exists"
    fi

    root_dotfiles=(
        "zshrc"
        "tmux.conf"
    )

    configs=(
        "zsh"
        "tmux"
        "zsh-abbr"
        "starship.toml"
    )

    # Create dotfiles config directory for custom user configurations
    if [[ ! -d "$HOME/.config/dots" ]]; then
        echo "📁 Creating ~/.config/dots directory"
        command mkdir -p "$HOME/.config/dots"
        echo "✅ Created ~/.config/dots directory"
    else
        echo "📁 ~/.config/dots directory already exists"
    fi

    for file in "${root_dotfiles[@]}"; do
        create_symlink "$DOTFILES_DIR/dots/$file" "$HOME/.$file" || true
    done

    for config in "${configs[@]}"; do
        create_symlink "$DOTFILES_DIR/config/$config" "$HOME/.config/$config" || true
    done

    # Link custom directory for user customizations
    create_symlink "$DOTFILES_DIR/custom" "$HOME/.config/dots/custom" || true

    echo ""
    echo "⚠️ GIT CONFIG IS NOT YET AUTOMATED"
    echo "💡 use 'dots doctor' to check recommended settings"
    echo ""

    echo "🎉 Dotfiles installation completed!"

    if [[ "$SHELL" != "$(which zsh)" ]]; then
        echo "🔧 Setting zsh as default shell"
        command chsh -s $(which zsh)
    fi

    echo "🔄 Restarting shell to apply changes"
    exec zsh
}

main "$@"
