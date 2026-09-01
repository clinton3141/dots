#!/usr/bin/env zsh

set -e

DOTFILES_DIR="${0:A:h}"

source "$DOTFILES_DIR/dots/dots.lock"
source "$DOTFILES_DIR/lib/trial.zsh"

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

check_target() {
    local target="$1"
    local expected_source="$2"

    if [[ -e "$target" ]]; then
        if [[ -L "$target" ]]; then
            local current_source="$(readlink "$target")"
            if [[ "$current_source" == "$expected_source" ]]; then
                return 0
            else
                return 2
            fi
        else
            return 2
        fi
    fi
    return 1
}

create_symlink() {
    local source="$1"
    local target="$2"

    local result
    check_target "$target" "$source"
    result=$?

    if [[ $result == 0 ]]; then
        echo "✅ $target is correctly linked"
    elif [[ $result == 1 ]]; then
        echo "🔗 Creating $target"
        command ln -s "$source" "$target"
        echo "✅ $target created successfully"
    elif [[ $result == 2 ]]; then
        if [[ "$TRIAL_MODE" == true ]]; then
            echo "📦 $target exists - backing up before replacing"
            backup_existing "$target"
            echo "🔗 Creating $target"
            command ln -s "$source" "$target"
            echo "✅ $target created successfully"
        else
            echo "⚠️  $target exists but is not a symlink"
        fi
    fi
}

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

    if [[ ! -d "$HOME/.config" ]]; then
        echo "📁 Creating ~/.config directory"
        command mkdir -p "$HOME/.config"
        echo "✅ Created ~/.config directory"
    else
        echo "📁 ~/.config directory already exists"
    fi

    root_dotfiles=(
        "zshrc"
        "tmux.conf"
    )

    configs=(
        "zsh"
        "tmux"
        "zsh-abbr"
        "starship.toml"
    )

    if [[ ! -d "$HOME/.config/dots" ]]; then
        echo "📁 Creating ~/.config/dots directory"
        command mkdir -p "$HOME/.config/dots"
        echo "✅ Created ~/.config/dots directory"
    else
        echo "📁 ~/.config/dots directory already exists"
    fi

    for file in "${root_dotfiles[@]}"; do
        create_symlink "$DOTFILES_DIR/dots/$file" "$HOME/.$file" || true
    done

    for config in "${configs[@]}"; do
        create_symlink "$DOTFILES_DIR/config/$config" "$HOME/.config/$config" || true
    done

    create_symlink "$DOTFILES_DIR/custom" "$HOME/.config/dots/custom" || true

    if [[ ! -d "$HOME/.claude" ]]; then
        echo "📁 Creating ~/.claude directory"
        command mkdir -p "$HOME/.claude"
        echo "✅ Created ~/.claude directory"
    else
        echo "📁 ~/.claude directory already exists"
    fi

    if [[ ! -d "$HOME/.agents" ]]; then
        echo "📁 Creating ~/.agents directory"
        command mkdir -p "$HOME/.agents"
        echo "✅ Created ~/.agents directory"
    else
        echo "📁 ~/.agents directory already exists"
    fi

    if [[ ! -d "$HOME/.copilot/instructions" ]]; then
        echo "📁 Creating ~/.copilot/instructions directory"
        command mkdir -p "$HOME/.copilot/instructions"
        echo "✅ Created ~/.copilot/instructions directory"
    else
        echo "📁 ~/.copilot/instructions directory already exists"
    fi

    claude_files=(
        "settings.json"
        "statusline.sh"
    )

    for file in "${claude_files[@]}"; do
        create_symlink "$DOTFILES_DIR/config/claude/$file" "$HOME/.claude/$file" || true
    done

    # one source of truth, read by Claude Code as memory and by Copilot's
    # default harness as an instructions file
    create_symlink "$DOTFILES_DIR/config/agents/agreements.md" \
        "$HOME/.claude/CLAUDE.md" || true

    create_symlink "$DOTFILES_DIR/config/agents/agreements.md" \
        "$HOME/.copilot/instructions/agreements.instructions.md" || true

    create_symlink "$DOTFILES_DIR/config/agents/skill-lock.json" "$HOME/.agents/.skill-lock.json" || true

    if command -v npx >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
        echo "📦 Restoring Claude Code skills from skill-lock.json"
        jq -r '.skills | to_entries | group_by(.value.source) | .[] | "\(.[0].value.source)\t\(map(.key) | join(" "))"' \
            "$DOTFILES_DIR/config/agents/skill-lock.json" \
        | while IFS=$'\t' read -r skill_source skill_names; do
            echo "📦 Installing $skill_names from $skill_source"
            # --skill takes one name per flag; a comma-joined list is read as a
            # single literal skill name and matches nothing
            skill_args=()
            for skill_name in ${=skill_names}; do
                skill_args+=(--skill "$skill_name")
            done
            # </dev/null: npx would otherwise read the loop's stdin and eat the
            # remaining sources
            if command npx --yes skills add -g "$skill_source" "${skill_args[@]}" -y </dev/null; then
                echo "✅ $skill_source skills installed"
            else
                echo "⚠️  failed to install skills from $skill_source"
            fi
        done
    else
        echo "⚠️  npx and jq are required to restore Claude Code skills - skipping"
    fi

    command mkdir -p "$HOME/.agents/skills"
    for skill in "$DOTFILES_DIR"/config/agents/skills/*(/N); do
        create_symlink "$skill" "$HOME/.agents/skills/${skill:t}" || true
    done


    echo ""
    echo "⚠️ GIT CONFIG IS NOT YET AUTOMATED"
    echo "💡 use 'dots doctor' to check recommended settings"
    echo ""

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
