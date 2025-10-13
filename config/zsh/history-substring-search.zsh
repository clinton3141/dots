zinit ice wait"0" lucid atload"_history_substring_search_config" ver"$DOTS_ZSH_HISTORY_SUBSTRING_SEARCH_HASH"
zinit load zsh-users/zsh-history-substring-search

_history_substring_search_config() {
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down

    bindkey -M vicmd 'k' history-substring-search-up
    bindkey -M vicmd 'j' history-substring-search-down
}

HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=green,standout'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='fg=red,standout'
HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS='i'