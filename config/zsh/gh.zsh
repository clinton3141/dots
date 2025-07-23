if command -v gh &> /dev/null; then
    if gh extension list | grep -q "github/gh-copilot"; then
        eval "$(gh copilot alias -- zsh)"
    fi
fi