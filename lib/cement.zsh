#!/usr/bin/env zsh

cement() {
    echo "🎯 Complete Trial and Commit to Dotfiles"
    echo ""

    if ! is_trial_mode; then
        echo "❌ Not in trial mode"
        return 1
    fi

    get_trial_status
    echo ""
    echo -n "Commit to using these dotfiles? (y/N): "
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo ""
        finalize_trial
    else
        echo "Cancelled"
        return 0
    fi
}
