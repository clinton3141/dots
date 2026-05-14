source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Use -C flag to skip checking if there are new functions (faster startup)
# Use -u flag to ignore insecure files (common with Homebrew installations)
ZINIT[COMPINIT_OPTS]="-C -u"

# Note: zicompinit and zicdreplay are called in syntax-highlighting.zsh atload hook
