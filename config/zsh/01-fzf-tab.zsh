zinit ice wait"0" lucid ver"$DOTS_FZF_TAB_HASH"
zinit load Aloxaf/fzf-tab

zstyle ':completion:*' menu no
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:warnings' format '[no matches found]'

zstyle ':completion:*' abbreviations group-order aliases commands functions builtins parameters

zstyle ':completion:*:git-checkout:*' sort false

zstyle ':fzf-tab:*' show-group full
zstyle ':fzf-tab:*' switch-group '<' '>'

if [[ -n "$TMUX" ]]; then
    # Use tmux popup
    zstyle ':fzf-tab:*' fzf-flags \
        --ansi \
        --color=bg:#1d2021,fg:#fbf1c7 \
        --color=bg+:#3c3836,fg+:#fbf1c7 \
        --color=hl:yellow,hl+:yellow \
        --color=info:cyan,border:#665c54 \
        --color=prompt:red,pointer:red \
        --color=marker:green,spinner:cyan \
        --color=header:cyan,gutter:#1d2021 \
        --color=query:#fbf1c7:regular \
        --border=rounded \
        --height=80% \
        --layout=reverse \
        --preview-window=right:50%:wrap \
        --bind=tab:down,shift-tab:up \
        --bind=ctrl-y:preview-up,ctrl-e:preview-down \
        --bind=ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down \
        --bind=ctrl-f:page-down,ctrl-b:page-up \
        --bind=ctrl-space:toggle,ctrl-a:select-all,ctrl-d:deselect-all \
        --tmux bottom,40%
else
    zstyle ':fzf-tab:*' fzf-flags \
        --ansi \
        --color=bg:#1d2021,fg:#fbf1c7 \
        --color=bg+:#3c3836,fg+:#fbf1c7 \
        --color=hl:yellow,hl+:yellow \
        --color=info:cyan,border:#665c54 \
        --color=prompt:red,pointer:red \
        --color=marker:green,spinner:cyan \
        --color=header:cyan,gutter:#1d2021 \
        --color=query:#fbf1c7:regular \
        --border=rounded \
        --height=80% \
        --layout=reverse \
        --preview-window=right:50%:wrap \
        --bind=tab:down,shift-tab:up \
        --bind=ctrl-y:preview-up,ctrl-e:preview-down \
        --bind=ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down \
        --bind=ctrl-f:page-down,ctrl-b:page-up \
        --bind=ctrl-space:toggle,ctrl-a:select-all,ctrl-d:deselect-all
fi

zstyle ':fzf-tab:complete:*:*' fzf-preview '
    if [[ -f $realpath ]]; then
        if (( $+commands[bat] )); then
            bat --color=always --style=numbers --line-range :200 $realpath 2>/dev/null
        else
            head -200 $realpath 2>/dev/null
        fi
    elif [[ -d $realpath ]]; then
        if (( $+commands[eza] )); then
            eza -1 --color=always --icons --group-directories-first $realpath 2>/dev/null
        else
            ls -1 --color=always $realpath 2>/dev/null
        fi
    fi'

zstyle ':fzf-tab:complete:(cd|ls):*' fzf-preview '
    if (( $+commands[eza] )); then
        eza -1 --color=always --icons $realpath 2>/dev/null
    else
        ls -1 --color=always $realpath 2>/dev/null
    fi'

zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
    '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap

zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview \
    'git diff --color=always $word 2>/dev/null'

zstyle ':fzf-tab:complete:git-log:*' fzf-preview \
    'git log --color=always --oneline --graph -10 $word 2>/dev/null'

zstyle ':fzf-tab:complete:git-show:*' fzf-preview \
    'git show --color=always $word 2>/dev/null'

zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview '
    case $group in
        "modified file") git diff --color=always $word ;;
        "recent commit object name") git show --color=always $word ;;
        *) git log --color=always --oneline --graph -10 $word ;;
    esac'

zstyle ':fzf-tab:complete:man:*' fzf-preview \
    'man $word 2>/dev/null | head -50'

zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview '
    if [[ -n ${(P)word} ]]; then
        printf "%s\n" "${(P)word}"
    elif (( $+commands[$word] )); then
        whence -f $word 2>/dev/null | head -1
    else
        echo "(unset or empty)"
    fi'
