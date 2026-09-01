#!/usr/bin/env zsh

set -e

DOTFILES_DIR="${0:A:h}"

source "$DOTFILES_DIR/dots/dots.lock"
source "$DOTFILES_DIR/lib/trial.zsh"
source "$DOTFILES_DIR/lib/link.zsh"
source "$DOTFILES_DIR/lib/skills.zsh"
source "$DOTFILES_DIR/lib/vscode.zsh"

TRIAL_MODE=false
for arg in "$@"; do
    case "$arg" in
        --trial)
            TRIAL_MODE=true
            ;;
        --help|-h)
            echo "Usage: $0 [--trial]"
            echo ""
            echo "Options:"
            echo "  --trial    Install in trial mode (backs up existing dotfiles)"
            echo "  --help     Show this help message"
            exit 0
            ;;
    esac
done

main() {
    if is_trial_mode && [[ "$TRIAL_MODE" == true ]]; then
        echo "❌ Already in trial mode"
        exit 1
    fi

    if [[ "$TRIAL_MODE" == true ]]; then
        echo "🧪 Installing in trial mode"
        init_trial
        echo ""
    fi

    echo "📋 checking prerequisites"
    if ! command -v zsh >/dev/null 2>&1; then
        echo "❌ FATAL ERROR: zsh is not installed on this system"
        exit 1
    fi
    echo "✅ zsh is installed"

    if [[ ! -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]]; then
        echo "🔌 zinit is required for zsh plugin management and performance optimization"
        echo ""
        read -q "?❓ Would you like to install zinit now? (y/n): "
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "📦 Installing zinit plugin manager..."
            command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
            command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
                echo "✅ zinit installed successfully" || \
                (echo "❌ zinit installation failed" && exit 1)
        else
            echo "❌ FATAL ERROR: zinit is required."
            exit 1
        fi
    else
        echo "✅ zinit is installed"
    fi

    echo ""

    echo "🚀 Starting dotfiles installation"

    if command -v tmux >/dev/null 2>&1; then
        echo "✅ tmux is installed"

        echo "📦 Installing tmux plugins"

        if [[ ! -d "$DOTFILES_DIR/config/tmux/plugins/tmux-sensible" ]]; then
            echo "📦 Installing tmux-sensible"
            command git clone https://github.com/tmux-plugins/tmux-sensible "$DOTFILES_DIR/config/tmux/plugins/tmux-sensible"
        else
            echo "✅ tmux-sensible is already installed"
        fi
        command git -C "$DOTFILES_DIR/config/tmux/plugins/tmux-sensible" fetch
        command git -C "$DOTFILES_DIR/config/tmux/plugins/tmux-sensible" checkout "$DOTS_TMUX_SENSIBLE_HASH"
        echo "✅ tmux-sensible pinned to hash $DOTS_TMUX_SENSIBLE_HASH"

        # Install monokai-pro.tmux
        if [[ ! -d "$DOTFILES_DIR/config/tmux/plugins/monokai-pro.tmux" ]]; then
            echo "📦 Installing monokai-pro.tmux"
            command git clone https://github.com/loctvl842/monokai-pro.tmux "$DOTFILES_DIR/config/tmux/plugins/monokai-pro.tmux"
        else
            echo "✅ monokai-pro.tmux is already installed"
        fi
        command git -C "$DOTFILES_DIR/config/tmux/plugins/monokai-pro.tmux" fetch
        command git -C "$DOTFILES_DIR/config/tmux/plugins/monokai-pro.tmux" checkout "$DOTS_MONOKAI_PRO_HASH"
        echo "✅ monokai-pro.tmux pinned to hash $DOTS_MONOKAI_PRO_HASH"
    else
        echo "⚠️  tmux is not installed - skipping tmux configuration"
    fi

    dots_link_all
    dots_restore_skills "$DOTFILES_DIR"
    dots_enable_vscode_claude_md

    echo ""
    echo "⚠️ GIT CONFIG IS NOT YET AUTOMATED"
    echo "💡 use 'dots doctor' to check recommended settings"
    echo ""

    # `if !` so errexit does not swallow the summary
    if ! dots_report_problems; then
        echo ""
        echo "❌ Dotfiles installation finished with problems - see above"
        exit 1
    fi

    echo "🎉 Dotfiles installation completed!"

    if [[ "$TRIAL_MODE" == true ]]; then
        echo ""
        echo "🧪 Trial mode active - run 'dots cement' or 'dots uninstall' when ready"
        echo ""
    fi

    if [[ "$SHELL" != "$(which zsh)" ]]; then
        echo "🔧 Setting zsh as default shell"
        command chsh -s $(which zsh)
    fi

    echo "🔄 Restarting shell to apply changes"
    exec zsh
}

main "$@"
