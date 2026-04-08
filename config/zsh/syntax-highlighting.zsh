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

    # ls/eza completion with zoxide frecent dirs
    command -v zoxide >/dev/null 2>&1 && command -v eza >/dev/null 2>&1 && compdef _ls_zoxide ls eza

    # cd completion with local dirs + zoxide frecent dirs
    command -v zoxide >/dev/null 2>&1 && compdef _cd_zoxide cd
'
zinit load zdharma-continuum/fast-syntax-highlighting
