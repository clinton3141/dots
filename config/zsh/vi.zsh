bindkey -v

if command -v nvim >/dev/null 2>&1; then
    alias vi='nvim'
elif command -v vim >/dev/null 2>&1; then
    alias vi='vim'
fi
