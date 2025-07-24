if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"

    cd() {
        if [ $# -eq 0 ]; then
            builtin cd
        elif [ "$1" = "-" ]; then
            builtin cd -
        elif [ -d "$1" ]; then
            builtin cd "$@"
        else
            z "$@" 2>/dev/null || builtin cd "$@"
        fi
    }
fi