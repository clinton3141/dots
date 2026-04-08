# Homebrew configuration for zsh

# Set Homebrew's prefix
if [[ -x "/opt/homebrew/bin/brew" ]]; then
    export HOMEBREW_PREFIX="/opt/homebrew"
elif [[ -x "/usr/local/bin/brew" ]]; then
    export HOMEBREW_PREFIX="/usr/local"
else
    export HOMEBREW_PREFIX=""
fi

# Add Homebrew to PATH
if [[ -n "$HOMEBREW_PREFIX" ]]; then
    export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"
fi

# Homebrew shell completions
# Add to fpath - compinit will be called later by zinit
if [[ -d "$HOMEBREW_PREFIX/share/zsh/site-functions" ]]; then
    fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)
fi

# Homebrew environment variables
export HOMEBREW_NO_AUTO_UPDATE=1   # Disable auto-update for faster brew commands
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
