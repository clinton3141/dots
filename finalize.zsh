#!/usr/bin/env zsh
# Finalize trial mode and make installation permanent

set -e

DOTFILES_DIR="${0:A:h}"

source "$DOTFILES_DIR/lib/trial.zsh"

main() {
    echo "🎯 Finalize Dotfiles Installation"
    echo ""

    if ! is_trial_mode; then
        echo "❌ Error: Not in trial mode"
        echo "   Installation is already permanent (or was never in trial mode)"
        exit 1
    fi

    get_trial_status
    echo ""
    echo "This will:"
    echo "   • Remove the backup directory"
    echo "   • Remove the trial lock file"
    echo "   • Make your dotfiles installation permanent"
    echo ""
    echo -n "Finalize the installation? (y/N): "
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo ""
        finalize_trial

        if [[ $? -eq 0 ]]; then
            echo ""
            echo "🎉 Success! Your dotfiles installation is now permanent."
            echo "   You can no longer use 'dots uninstall' to restore the backup."
        else
            echo ""
            echo "❌ Finalization failed. Please check the errors above."
            exit 1
        fi
    else
        echo ""
        echo "Cancelled. You remain in trial mode."
        echo "   Use 'dots finalize' or 'dots uninstall' when ready."
        exit 0
    fi
}

main "$@"
