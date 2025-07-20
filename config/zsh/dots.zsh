function dots() {
    case "$1" in
        reload|r)
            echo "Reloading zsh configuration..."
            exec zsh
            ;;
        doctor|d)
            echo "Running dotfiles diagnostics..."
            echo "Checking for recommended tools..."
            tools=("z" "fzf" "bat" "starship" "eza" "fd")
            for tool in "${tools[@]}"; do
                if command -v "$tool" >/dev/null 2>&1; then
                    echo "✅ $tool is installed."
                else
                    echo "❌ $tool is NOT installed."
                fi
            done
            ;;
        *)
            echo "Usage: dots {reload|doctor}"
            echo ""
            echo "Available commands:"
            echo "  reload    Reload zsh configuration"
            echo "  doctor    Run dotfiles diagnostics (TODO)"
            return 1
            ;;
    esac
}

alias ...='dots'