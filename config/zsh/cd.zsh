# Zoxide - completion will be set up after zicompinit in syntax-highlighting atload
# Just make zoxide available, don't set up completion yet
command -v zoxide >/dev/null 2>&1

# Mix local dirs and zoxide frecent dirs into cd tab completion (compdef registered in syntax-highlighting.zsh after compinit)
_cd_zoxide() {
    _files -/
    local -a zoxide_dirs
    local query="${PREFIX}${SUFFIX}"
    if [[ -n "$query" ]]; then
        zoxide_dirs=(${(f)"$(zoxide query -l -- "$query" 2>/dev/null)"})
    else
        zoxide_dirs=(${(f)"$(zoxide query -l 2>/dev/null)"})
    fi
    (( $#zoxide_dirs )) && compadd -U -X '[frecent dirs]' -- "${zoxide_dirs[@]}"
}
