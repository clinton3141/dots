if command -v fzf > /dev/null; then
    source <(fzf --zsh)
else
    return
fi

export FZF_DEFAULT_OPTS="
    --height 40%
    --layout=reverse
    --border
    --preview 'command -v bat >/dev/null && bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || cat {}'
    --preview-window=right:60%
    --bind 'ctrl-y:preview-up'
    --bind 'ctrl-e:preview-down'
    --color=bg+:#1d1f21,bg:#282a36,spinner:#bd93f9,hl:#8be9fd
"

export FZF_COMPLETION_TRIGGER='**'

# Use rg > fd for file search (rg is faster for large repos)
if command -v rg > /dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*" --glob "!node_modules/*" --glob "!.cache/*"'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
elif command -v fd > /dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude node_modules --exclude .cache'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

[ -n "$FZF_TMUX" ] || export FZF_TMUX=1
