zinit ice wait"0" lucid ver"$DOTS_ZSH_AUTOSUGGESTIONS_HASH"
zinit load zsh-users/zsh-autosuggestions

if [[ -n "$TMUX" ]]; then
    export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=240"
else
    export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
fi
