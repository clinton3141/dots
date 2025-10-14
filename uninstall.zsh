#!/usr/bin/env zsh
# Uninstall script for dotfiles (trial mode only)

set -e

DOTFILES_DIR="${0:A:h}"

source "$DOTFILES_DIR/lib/trial.zsh"

main() {
    echo "🗑️  Dotfiles Uninstaller"
    echo ""

    if ! is_trial_mode; then
        echo "❌ Error: Not in trial mode"
        echo ""
        echo "💡 Trial mode is used to safely try dotfiles with the ability to uninstall."
        echo "   This script only works if you installed with './install.zsh --trial'"
        echo ""
        echo "   If you want to manually remove the dotfiles, delete the symlinks:"
        echo "     • ~/.zshrc"
        echo "     • ~/.tmux.conf"
        echo "     • ~/.config/zsh"
        echo "     • ~/.config/tmux"
        echo "     • ~/.config/zsh-abbr"
        echo "     • ~/.config/starship.toml"
        echo "     • ~/.config/dots/custom"
        echo ""
        exit 1
    fi

    get_trial_status
    echo ""
    echo "⚠️  This will:"
    echo "   • Remove all dotfiles symlinks"
    echo "   • Restore your original configuration from backup"
    echo "   • Remove the backup directory and trial lock file"
    echo ""
    echo -n "Are you sure you want to uninstall? (y/N): "
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo ""
        restore_trial

        if [[ $? -eq 0 ]]; then
            echo ""
            echo "👋 Dotfiles have been uninstalled successfully!"
            echo "   Your original setup has been restored."
            echo ""
            echo "   Restarting shell..."
            exec zsh
        else
            echo ""
            echo "❌ Uninstallation failed. Please check the errors above."
            exit 1
        fi
    else
        echo ""
        echo "Cancelled. No changes made."
        exit 0
    fi
}

main "$@"
