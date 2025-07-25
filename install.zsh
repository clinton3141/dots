#!/usr/bin/env zsh

set -e

DOTFILES_DIR="${0:A:h}"

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
        ln -s "$source" "$target"
        echo "✅ $target created successfully"
    elif [[ $result == 2 ]]; then
        echo "⚠️  $target exists but is not a symlink"
    fi
}

main() {
    if ! command -v zsh >/dev/null 2>&1; then
        echo "❌ FATAL ERROR: zsh is not installed on this system"
        exit 1
    fi
    echo "✅ zsh is installed"

    echo "🚀 Starting dotfiles installation"

    echo "📦 Initializing and updating git submodules"
    git -C "$DOTFILES_DIR" submodule update --init --recursive
    echo "✅ Git submodules initialised"

    if [[ ! -d "$HOME/.config" ]]; then
        echo "📁 Creating ~/.config directory"
        mkdir -p "$HOME/.config"
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
        mkdir -p "$HOME/.config/dots"
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
        chsh -s $(which zsh)
    fi

    echo "🔄 Restarting shell to apply changes"
    exec zsh
}

main "$@"
