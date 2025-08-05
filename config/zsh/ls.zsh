if command -v eza >/dev/null 2>&1; then
    alias ls='eza --color=auto --group-directories-first --icons auto'
    alias ll='eza -l --color=auto --group-directories-first --icons auto'
    alias la='eza -lah --color=auto --group-directories-first --icons auto'
    alias lt='eza --tree --color=auto --group-directories-first --icons auto'
    alias lg='eza -l --git --color=auto --group-directories-first --icons auto'
    alias lh='eza -la --header --color=auto --group-directories-first --icons auto'
else
    # Fallback to standard ls with color output if available
    if command -v ls > /dev/null; then
        if ls --color=auto > /dev/null 2>&1; then
            alias ls='ls --color=auto'
        elif ls -G > /dev/null 2>&1; then
            alias ls='ls -G'
        fi
    fi

    alias ll='ls -l'
    alias la='ls -lah'
fi

# Enable colours for completion matches (if using zsh completion)
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
