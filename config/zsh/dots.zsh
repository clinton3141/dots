local DOTFILES_DIR="${${(%):-%x}:A:h:h:h}"

check_symlink_health() {
    local target="$1"
    local expected_source="$2"
    local name="$3"

    if [[ -e "$target" ]]; then
        if [[ -L "$target" ]]; then
            local current_source="$(readlink "$target")"
            if [[ "$current_source" == "$expected_source" ]]; then
                echo "✅ $name is correctly linked"
            else
                echo "❌ $name points to wrong location: $current_source (expected: $expected_source)"
            fi
        else
            echo "⚠️ $name exists but is not a symlink"
        fi
    else
        echo "❌ $name is missing"
    fi
}

doctor() {
    echo "🩺 CHECKING DOTFILES HEALTH "
    echo ""
    echo "🔧 RECOMMENDED TOOLS"
    tools=("bat" "code" "delta" "eza" "fd" "fzf" "gh" "jq" "nvim" "starship" "tmux" "z")
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "✅ $tool is installed"
        else
            echo "❌ $tool is NOT installed"
        fi
    done

    echo ""
    echo "🔗 SYMLINKS"

    root_dotfiles=(
        "zshrc"
        "tmux.conf"
    )

    config_dirs=(
        "zsh"
        "tmux"
    )

    for file in "${root_dotfiles[@]}"; do
        check_symlink_health "$HOME/.$file" "$DOTFILES_DIR/dots/$file" "~/.$file"
    done

    for dir in "${config_dirs[@]}"; do
        check_symlink_health "$HOME/.config/$dir" "$DOTFILES_DIR/config/$dir" "~/.config/$dir"
    done

    # Check custom directory symlink
    check_symlink_health "$HOME/.config/dots/custom" "$DOTFILES_DIR/custom" "~/.config/dots/custom"

    echo ""
    echo "🐙 GIT"
    if [[ "$(git config --global core.pager)" == "delta" ]]; then
        echo "✅ core.pager is set to delta"
    else
        echo "❌ core.pager is not set to delta"
        echo "fix by running: 'git config --global core.pager delta'"
    fi
    if [[ "$(git config --global interactive.diffFilter)" == "delta --color-only" ]]; then
        echo "✅ interactive.diffFilter is set to delta --color-only"
    else
        echo "❌ interactive.diffFilter is not set to delta --color-only"
        echo "fix by running: 'git config --global interactive.diffFilter \"delta --color-only\"'"
    fi
    if [[ "$(git config --global delta.navigate)" == "true" ]]; then
        echo "✅ delta.navigate is set to true"
    else
        echo "❌ delta.navigate is not set to true"
        echo "fix by running: 'git config --global delta.navigate true'"
    fi
    if [[ "$(git config --global pull.rebase)" == "true" ]]; then
        echo "✅ pull.rebase is set to true"
    else
        echo "❌ pull.rebase is not set to true"
        echo "fix by running: 'git config --global pull.rebase true'"
    fi
    if [[ "$(git config --global init.defaultBranch)" == "main" ]]; then
        echo "✅ init.defaultBranch is set to main"
    else
        echo "❌ init.defaultBranch is not set to main"
        echo "fix by running: 'git config --global init.defaultBranch main'"
    fi
    if [[ "$(git config --global rerere.enabled)" == "true" ]]; then
        echo "✅ rerere.enabled is set to true"
    else
        echo "❌ rerere.enabled is not set to true"
        echo "fix by running: 'git config --global rerere.enabled true'"
    fi
    if [[ "$(git config --global merge.conflictstyle)" == "diff3" ]]; then
        echo "✅ merge.conflictstyle is set to diff3"
    else
        echo "❌ merge.conflictstyle is not set to diff3"
        echo "fix by running: 'git config --global merge.conflictstyle diff3'"
    fi
    echo ""
    echo "🐙 GITHUB CLI"
    if command -v "gh" >/dev/null 2>&1; then
        if gh auth status >/dev/null 2>&1; then
            echo "✅ gh is authenticated"
        else
            echo "❌ gh is not authenticated"
            echo "fix by running: 'gh auth login'"
        fi
        if gh extension list | grep -q "github/gh-copilot"; then
            echo "✅ gh copilot extension is installed"
        else
            echo "❌ gh copilot extension is not installed"
            echo "fix by running: 'gh extension install github/gh-copilot'"
        fi
    fi
}

update() {
    echo "🏗️ Updating dotfiles..."
    git -C $DOTFILES_DIR pull
    git -C $DOTFILES_DIR submodule update --init --recursive
    echo "✅ Dotfiles updated successfully."
}

reload() {
    echo "🪚 Reloading zsh configuration..."
    exec zsh
}

function dots() {
    case "$1" in
        reload|r)
            reload
            ;;
        doctor|d)
            doctor
            ;;
        update|u)
            update
            ;;
        *)
            echo "Usage: dots {reload|doctor}"
            echo ""
            echo "Available commands:"
            echo "  reload    Reload zsh configuration"
            echo "  doctor    Run dotfiles diagnostics"
            echo "  update    Update dotfiles"
            return 1
            ;;
    esac
}

alias ...='dots'
alias .r='dots reload'
alias .d='dots doctor'
alias .u='dots update'