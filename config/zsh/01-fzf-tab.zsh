zinit ice wait"0" lucid ver"$DOTS_FZF_TAB_HASH"
zinit load Aloxaf/fzf-tab

zstyle ':completion:*' menu no
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:messages' format '[%d]'
zstyle ':completion:*:warnings' format '[no matches found]'
zstyle ':completion:*:abbreviations' format '[abbr]'
zstyle ':completion:*:commands' format '[external command]'
zstyle ':completion:*:functions' format '[function]'
zstyle ':completion:*:builtins' format '[builtin]'
zstyle ':completion:*:aliases' format '[alias]'
zstyle ':completion:*:parameters' format '[parameter]'

zstyle ':completion:*' group-order abbreviations aliases commands functions builtins parameters

zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || ls -1 --color=always $realpath'

zstyle ':completion:*:git-checkout:*' sort false
zstyle ':fzf-tab:*' show-group full
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:down,shift-tab:up,ctrl-y:preview-up,ctrl-e:preview-down

# Switch group using '<' and '>'
zstyle ':fzf-tab:*' switch-group '<' '>'

# Previews
zstyle ':fzf-tab:complete:*:*' fzf-preview 'if [[ -f $realpath ]]; then
    if command -v bat >/dev/null 2>&1; then
        bat --color=always --style=numbers --line-range :500 $realpath 2>/dev/null
    else
        head -200 $realpath 2>/dev/null
    fi
elif [[ -d $realpath ]]; then
    if command -v eza >/dev/null 2>&1; then
        eza -1 --color=always $realpath 2>/dev/null
    else
        ls -1 --color=always $realpath 2>/dev/null
    fi
else
    echo "No preview available"
fi'

zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
  '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap

zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview \
    'git diff $word 2>/dev/null | head -200'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview \
    'git log --color=always $word'
zstyle ':fzf-tab:complete:git-show:*' fzf-preview \
    'case "$group" in
    "commit tag") git show --color=always $word ;;
    *) git show --color=always $word ;;
    esac'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
    'case "$group" in
    "modified file") git diff $word ;;
    "recent commit object name") git show --color=always $word ;;
    *) git log --color=always $word ;;
    esac'

zstyle ':fzf-tab:complete:man:*' fzf-preview 'man $word'

zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
    fzf-preview 'echo ${(P)word}'
