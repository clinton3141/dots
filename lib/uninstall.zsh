#!/usr/bin/env zsh

uninstall() {
    echo "🗑️  Dotfiles Uninstaller"
    echo ""

    if ! is_trial_mode; then
        echo "❌ Not in trial mode"
        echo "   This only works if you installed with './install.zsh --trial'"
        return 1
    fi

    get_trial_status
    echo ""
    echo -n "Uninstall and restore original dotfiles? (y/N): "
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo ""
        if restore_trial; then
            echo ""
            echo "👋 Original dotfiles restored"
            echo "   Reloading shell..."
            exec zsh
        else
            return 1
        fi
    else
        echo "Cancelled"
        return 0
    fi
}
