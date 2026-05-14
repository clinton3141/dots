# zoxide init and compdef are deferred to syntax-highlighting.zsh atload (after compinit)

# Shared helper: appends zoxide frecent dirs to any completion function
_zoxide_compadd() {
    local -a zoxide_dirs
    local query="${PREFIX}${SUFFIX}"
    if [[ -n "$query" ]]; then
        zoxide_dirs=(${(f)"$(zoxide query -l -- "$query" 2>/dev/null)"})
    else
        zoxide_dirs=(${(f)"$(zoxide query -l 2>/dev/null)"})
    fi
    (( $#zoxide_dirs )) && compadd -U -X '[frecent dirs]' -- "${zoxide_dirs[@]}"
}

# Mix local dirs and zoxide frecent dirs into cd tab completion (compdef registered in syntax-highlighting.zsh after compinit)
_cd_zoxide() {
    _files -/
    _zoxide_compadd
}
