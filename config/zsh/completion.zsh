setopt COMPLETE_ALIASES
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt PATH_DIRS
setopt AUTO_MENU
setopt AUTO_LIST
setopt AUTO_PARAM_SLASH
unsetopt MENU_COMPLETE
unsetopt FLOW_CONTROL

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'


zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path ~/.zsh/cache

zstyle ':completion:*:cd:*' ignore-parents parent pwd
zstyle ':completion:*' squeeze-slashes true

zstyle ':completion:*' file-sort modification
zstyle ':completion:*' list-suffixes true

zstyle ':completion:*' completer _complete _correct _approximate

# Allow some typos in completion
zstyle ':completion:*:approximate:*' max-errors 1 numeric

zstyle ':completion:*' complete-options true

# Better process completion
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

_abbr_completion() {
  if [[ $CURRENT -eq 1 ]]; then
    local -a abbr_matches
    local abbreviations_file="$HOME/.config/zsh-abbr/user-abbreviations"

    if [[ -f "$abbreviations_file" ]]; then
      while IFS= read -r line; do
        if [[ "$line" == abbr* ]]; then
          local abbr_name="${line#*\"}"
          abbr_name="${abbr_name%%\"*}"

          if [[ -n "$abbr_name" ]]; then
            # Extract expansion for description
            local expansion="${line#*=\"}"
            expansion="${expansion%\"*}"
            expansion="${expansion//\\\"/\"}"
            expansion="${expansion//\%/}"

            abbr_matches+=("$abbr_name:$expansion")
          fi
        fi
      done < "$abbreviations_file"

      if (( ${#abbr_matches} > 0 )); then
        _describe -t abbreviations 'abbr' abbr_matches
      fi
    fi
  fi

  return 1
}

zstyle ':completion:*' completer _abbr_completion _complete _ignored _approximate
