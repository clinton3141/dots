source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Use -u flag to ignore insecure files (common with Homebrew installations)
ZINIT[COMPINIT_OPTS]="-u"
zicompinit
zicdreplay
