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

        if [[ ! -d "$DOTFILES_DIR/config/tmux/plugins/tpm" ]]; then
            echo "📦 Installing tpm for tmux"
            command git clone https://github.com/tmux-plugins/tpm "$DOTFILES_DIR/config/tmux/plugins/tpm"
            echo "✅ tpm installed successfully"
        else
            echo "✅ tpm is already installed"
        fi

        command git -C "$DOTFILES_DIR/config/tmux/plugins/tpm" fetch
        command git -C "$DOTFILES_DIR/config/tmux/plugins/tpm" checkout "$DOTS_TPM_HASH"

        echo "📝 Generating tmux plugin configurations"

        cat > "$DOTFILES_DIR/config/tmux/conf/plugins.conf" << EOF
set -g @plugin 'loctvl842/monokai-pro.tmux#$DOTS_MONOKAI_PRO_HASH'

set -g @plugin 'tmux-plugins/tmux-sensible#$DOTS_TMUX_SENSIBLE_HASH'

set -g @plugin 'tmux-plugins/tpm#$DOTS_TPM_HASH'
run '~/.config/tmux/plugins/tpm/tpm'
EOF

        echo "✅ tmux plugin configurations generated"
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

    config_dirs=(
        "zsh"
        "tmux"
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

    for dir in "${config_dirs[@]}"; do
        create_symlink "$DOTFILES_DIR/config/$dir" "$HOME/.config/$dir" || true
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
