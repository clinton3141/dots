[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export FZF_DEFAULT_OPTS="
    --height 40%
    --layout=reverse
    --border
    --preview 'command -v bat >/dev/null && bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || cat {}'
    --preview-window=right:60%
    --color=bg+:#1d1f21,bg:#282a36,spinner:#bd93f9,hl:#8be9fd
"

# Use fd (if available) for fzf file search
if command -v fd > /dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

[ -n "$FZF_TMUX" ] || export FZF_TMUX=1