zinit ice wait"0" lucid ver"$DOTS_FAST_SYNTAX_HIGHLIGHTING_HASH" atload'
    zicompinit
    zicdreplay

    # Now set up completions that require compdef to be available
    # Docker completion
    command -v docker >/dev/null 2>&1 && eval "$(docker completion zsh)"

    # Zoxide completion
    command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh --cmd cd)"

    # Source any custom compdef registrations
    for f in ~/.config/dots/custom/*.compdef.zsh(N); do source "$f"; done

    # ls/eza completion with zoxide frecent dirs
    command -v zoxide >/dev/null 2>&1 && command -v eza >/dev/null 2>&1 && compdef _ls_zoxide ls eza

    # cd completion with local dirs + zoxide frecent dirs
    command -v zoxide >/dev/null 2>&1 && compdef _cd_zoxide cd
'
zinit load zdharma-continuum/fast-syntax-highlighting
