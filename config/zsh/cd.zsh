# common locations for z.sh
if [ -f /usr/share/z/z.sh ]; then
    . /usr/share/z/z.sh
elif [ -f /usr/local/etc/profile.d/z.sh ]; then
    . /usr/local/etc/profile.d/z.sh
elif [ -f "$HOME/.z.sh" ]; then
    . "$HOME/.z.sh"
elif [ -f /opt/homebrew/etc/profile.d/z.sh ]; then
    . /opt/homebrew/etc/profile.d/z.sh
fi

if command -v z >/dev/null 2>&1; then
    # use z for known paths, fallback to cd otherwise
    cd() {
        if [ $# -eq 0 ]; then
            builtin cd
        elif [ -d "$1" ]; then
            builtin cd "$@"
        else
            z "$@" 2>/dev/null || builtin cd "$@"
        fi
    }

    export _Z_DATA="$HOME/.z"
    export _Z_NO_PROMPT_COMMAND=1
    export _Z_EXCLUDE_DIRS="$HOME/tmp:$HOME/.cache"
fi