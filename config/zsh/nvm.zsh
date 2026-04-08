return
if [ -d "$HOME/.nvm" ]; then
  export NVM_DIR="$HOME/.nvm"
  source "$NVM_DIR/nvm.sh"
  source "$NVM_DIR/bash_completion"
fi
