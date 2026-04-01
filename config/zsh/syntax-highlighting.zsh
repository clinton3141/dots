zinit ice wait"0" lucid ver"$DOTS_FAST_SYNTAX_HIGHLIGHTING_HASH" atload'
    zicompinit
    zicdreplay

    # Now set up completions that require compdef to be available
    # Docker completion
    command -v docker >/dev/null 2>&1 && eval "$(docker completion zsh)"

    # Zoxide completion
    command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh --cmd cd)"

    # Mayden completion
    compdef _mayden_completion mayden 2>/dev/null
    compdef _mayden_completion m 2>/dev/null
'
zinit load zdharma-continuum/fast-syntax-highlighting
