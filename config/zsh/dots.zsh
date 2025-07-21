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
            echo "⚠️  $name exists but is not a symlink"
        fi
    else
        echo "❌ $name is missing"
    fi
}

function dots() {
    case "$1" in
        reload|r)
            echo "Reloading zsh configuration..."
            exec zsh
            ;;
        doctor|d)
            echo "Running dotfiles diagnostics..."
            echo ""
            echo "Checking for recommended tools..."
            tools=("z" "fzf" "bat" "starship" "eza" "fd")
            for tool in "${tools[@]}"; do
                if command -v "$tool" >/dev/null 2>&1; then
                    echo "✅ $tool is installed"
                else
                    echo "❌ $tool is NOT installed"
                fi
            done

            echo ""
            echo "Checking symlink health..."
            DOTFILES_DIR="$(realpath "$(dirname "${(%):-%x}")/../..")"

            root_dotfiles=(
                "zshrc"
                "tmux.conf"
            )

            config_dirs=(
                "zsh"
                "tmux"
            )

            for file in "${root_dotfiles[@]}"; do
                check_symlink_health "$HOME/.$file" "$DOTFILES_DIR/$file" "~/.$file"
            done

            for dir in "${config_dirs[@]}"; do
                check_symlink_health "$HOME/.config/$dir" "$DOTFILES_DIR/config/$dir" "~/.config/$dir"
            done
            ;;
        *)
            echo "Usage: dots {reload|doctor}"
            echo ""
            echo "Available commands:"
            echo "  reload    Reload zsh configuration"
            echo "  doctor    Run dotfiles diagnostics"
            return 1
            ;;
    esac
}

alias ...='dots'
alias .r='dots reload'
alias .d='dots doctor'