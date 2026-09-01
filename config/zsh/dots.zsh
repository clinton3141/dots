local DOTFILES_DIR="${${(%):-%x}:A:h:h:h}"

source "$DOTFILES_DIR/dots/dots.lock"
source "$DOTFILES_DIR/lib/trial.zsh"
source "$DOTFILES_DIR/lib/cement.zsh"
source "$DOTFILES_DIR/lib/uninstall.zsh"
source "$DOTFILES_DIR/lib/link.zsh"
source "$DOTFILES_DIR/lib/skills.zsh"
source "$DOTFILES_DIR/lib/vscode.zsh"

check_symlink_health() {
    local target="$1"
    local expected_source="$2"
    local name="$3"

    if [[ -e "$target" ]]; then
        if [[ -L "$target" ]]; then
            local current_source="$(readlink "$target")"
            if [[ "$current_source" == "$expected_source" ]]; then
                echo "✅ $name is correctly linked"
            else
                echo "❌ $name points to wrong location: $current_source (expected: $expected_source)"
            fi
        else
            echo "⚠️ $name exists but is not a symlink"
        fi
    else
        echo "❌ $name is missing"
    fi
}

doctor() {
    echo "🩺 CHECKING DOTFILES HEALTH "
    echo ""

    echo "🔧 RECOMMENDED TOOLS"
    local tools=("bat" "code" "delta" "eza" "fd" "fzf" "gh" "jq" "nvim" "starship" "tmux" "zoxide")
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "✅ $tool is installed"
        else
            echo "❌ $tool is NOT installed"
        fi
    done
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if brew list zsh-completions >/dev/null 2>&1; then
            echo "✅ zsh-completions is installed (via Homebrew)"
        else
            echo "❌ zsh-completions is NOT installed (via Homebrew)"
            echo "fix by running: 'brew install zsh-completions'"
        fi
    else
        # Check common locations for zsh-completions
        if [[ -d "/usr/share/zsh-completions" ]] || [[ -d "/usr/share/zsh/plugins/zsh-completions" ]] || [[ -d "/usr/local/share/zsh-completions" ]]; then
            echo "✅ zsh-completions is installed"
        else
            echo "❌ zsh-completions is NOT installed"
            echo "fix it by installing zsh-completions with your package manager"
        fi
    fi

    echo ""
    echo "🔗 SYMLINKS"

    local entry source target
    for entry in ${(f)"$(dots_link_map "$DOTFILES_DIR")"}; do
        source="${entry%%$'\t'*}"
        target="${entry#*$'\t'}"
        check_symlink_health "$target" "$source" "${target/#$HOME/~}"
    done

    echo ""
    echo "🆚 VS CODE"
    local vscode_setting="$(dots_vscode_setting_value)"
    case "$vscode_setting" in
        true)  echo "✅ $DOTS_VSCODE_SETTING is enabled" ;;
        unset|false)
            echo "❌ $DOTS_VSCODE_SETTING is $vscode_setting - ~/.claude/CLAUDE.md is ignored in VS Code"
            echo "fix by running: 'dots link'"
            ;;
        *) echo "⚠️ could not read $(dots_vscode_settings_file)" ;;
    esac

    echo ""
    echo "📦 TMUX"
    if command -v "tmux" >/dev/null 2>&1; then
        # Check tmux-sensible
        if [[ -d "$DOTFILES_DIR/config/tmux/plugins/tmux-sensible" ]]; then
            echo "✅ tmux-sensible is installed"
            local sensible_current_hash="$(git -C "$DOTFILES_DIR/config/tmux/plugins/tmux-sensible" rev-parse HEAD 2>/dev/null)"
            if [[ "$sensible_current_hash" == "$DOTS_TMUX_SENSIBLE_HASH" ]]; then
                echo "✅ tmux-sensible is at expected commit ($DOTS_TMUX_SENSIBLE_HASH)"
            else
                echo "❌ tmux-sensible is at wrong commit: $sensible_current_hash (expected: $DOTS_TMUX_SENSIBLE_HASH)"
                echo "fix by running: 'git -C $DOTFILES_DIR/config/tmux/plugins/tmux-sensible checkout $DOTS_TMUX_SENSIBLE_HASH'"
            fi
        else
            echo "❌ tmux-sensible is NOT installed"
            echo "fix by running the install script or: 'git clone https://github.com/tmux-plugins/tmux-sensible $DOTFILES_DIR/config/tmux/plugins/tmux-sensible'"
        fi

        # Check monokai-pro.tmux
        if [[ -d "$DOTFILES_DIR/config/tmux/plugins/monokai-pro.tmux" ]]; then
            echo "✅ monokai-pro.tmux is installed"
            local monokai_current_hash="$(git -C "$DOTFILES_DIR/config/tmux/plugins/monokai-pro.tmux" rev-parse HEAD 2>/dev/null)"
            if [[ "$monokai_current_hash" == "$DOTS_MONOKAI_PRO_HASH" ]]; then
                echo "✅ monokai-pro.tmux is at expected commit ($DOTS_MONOKAI_PRO_HASH)"
            else
                echo "❌ monokai-pro.tmux is at wrong commit: $monokai_current_hash (expected: $DOTS_MONOKAI_PRO_HASH)"
                echo "fix by running: 'git -C $DOTFILES_DIR/config/tmux/plugins/monokai-pro.tmux checkout $DOTS_MONOKAI_PRO_HASH'"
            fi
        else
            echo "❌ monokai-pro.tmux is NOT installed"
            echo "fix by running the install script or: 'git clone https://github.com/loctvl842/monokai-pro.tmux $DOTFILES_DIR/config/tmux/plugins/monokai-pro.tmux'"
        fi
    fi

    echo ""
    echo "🐙 GIT"
    if [[ "$(git config --global core.pager)" == "delta" ]]; then
        echo "✅ core.pager is set to delta"
    else
        echo "❌ core.pager is not set to delta"
        echo "fix by running: 'git config --global core.pager delta'"
    fi
    if [[ "$(git config --global interactive.diffFilter)" == "delta --color-only" ]]; then
        echo "✅ interactive.diffFilter is set to delta --color-only"
    else
        echo "❌ interactive.diffFilter is not set to delta --color-only"
        echo "fix by running: 'git config --global interactive.diffFilter \"delta --color-only\"'"
    fi
    if [[ "$(git config --global delta.navigate)" == "true" ]]; then
        echo "✅ delta.navigate is set to true"
    else
        echo "❌ delta.navigate is not set to true"
        echo "fix by running: 'git config --global delta.navigate true'"
    fi
    if [[ "$(git config --global pull.rebase)" == "false" ]]; then
        echo "✅ pull.rebase is set to false"
    else
        echo "❌ pull.rebase is not set to false"
        echo "fix by running: 'git config --global pull.rebase false'"
    fi
    if [[ "$(git config --global pull.ff)" == "only" ]]; then
        echo "✅ pull.ff set to only"
    else
        echo "❌ pull.ff is not set to only"
        echo "fix by running: 'git config --global pull.ff only'"
    fi
    if [[ "$(git config --global init.defaultBranch)" == "main" ]]; then
        echo "✅ init.defaultBranch is set to main"
    else
        echo "❌ init.defaultBranch is not set to main"
        echo "fix by running: 'git config --global init.defaultBranch main'"
    fi
    if [[ "$(git config --global push.autoSetupRemote)" == "true" ]]; then
        echo "✅ push.autoSetupRemote is set to true"
    else 
        echo "❌ push.autoSetupRemote is not set to true"
        echo "fix by running: 'git config --global push.autoSetupRemote true'"
    fi
    if [[ "$(git config --global rerere.enabled)" == "true" ]]; then
        echo "✅ rerere.enabled is set to true"
    else
        echo "❌ rerere.enabled is not set to true"
        echo "fix by running: 'git config --global rerere.enabled true'"
    fi
    if [[ "$(git config --global merge.conflictstyle)" == "diff3" ]]; then
        echo "✅ merge.conflictstyle is set to diff3"
    else
        echo "❌ merge.conflictstyle is not set to diff3"
        echo "fix by running: 'git config --global merge.conflictstyle diff3'"
    fi
    if [[ "$(git config --global advice.detachedHead)" == "false" ]]; then
        echo "✅ advice.detachedHead is set to false"
    else
        echo "❌ advice.detachedHead is not set to false"
        echo "fix by running: 'git config --global advice.detachedHead false'"
    fi

    echo ""
    echo "🐙 GITHUB CLI"
    if command -v "gh" >/dev/null 2>&1; then
        if gh auth status >/dev/null 2>&1; then
            echo "✅ gh is authenticated"
        else
            echo "❌ gh is not authenticated"
            echo "fix by running: 'gh auth login'"
        fi
        if gh extension list | grep -q "github/gh-copilot"; then
            echo "✅ gh copilot extension is installed"
        else
            echo "❌ gh copilot extension is not installed"
            echo "fix by running: 'gh extension install github/gh-copilot'"
        fi
    fi

    if command -v "starship" >/dev/null 2>&1; then
        echo ""
        echo "🚀 STARSHIP PERFORMANCE"
        local timings_output total_ms
        timings_output="$(starship timings 2>/dev/null)"
        if [[ -n "$timings_output" ]]; then
            echo "$timings_output"
            total_ms=$(echo "$timings_output" | grep 'git_status' | grep -o '[0-9]+')
            if [[ "$total_ms" =~ ^[0-9]+$ ]] && (( total_ms > 2 )); then
                echo "❌ starship is slow: total time ${total_ms}ms (>200ms)"
                echo "Suggestions to improve git performance (especially for large repos):"
                echo "  git config feature.manyFiles true"
                echo "  git update-index --index-version 4"
                echo "  git config core.fsmonitor true"
                echo "     confirm with: git fsmonitor--daemon status"
                echo "  git config core.untrackedcache true"
            else
                echo "✅ starship timings: total time ${total_ms}ms"
            fi
        else
            echo "⚠️ Could not get starship timings"
        fi
    fi

    if is_trial_mode; then
        echo "🧪 TRIAL MODE"
        get_trial_status
        echo ""
    fi
}

# named link_dots, not link, so it does not shadow the link(1) utility
link_dots() {
    echo "🔗 Linking dotfiles"
    DOTS_PROBLEMS=()
    dots_link_all
    dots_enable_vscode_claude_md
    dots_report_problems
}

update() {
    echo "🏗️ Updating dotfiles"
    DOTS_PROBLEMS=()
    git -C $DOTFILES_DIR pull
    echo "✅ Dotfiles git repository updated"

    # a pull can add files that have never been linked; without this the new
    # config sits in the repo and never reaches $HOME
    echo "🔗 Linking dotfiles"
    dots_link_all
    dots_restore_skills "$DOTFILES_DIR"
    dots_enable_vscode_claude_md

    echo "🔌 Updating Zinit and plugins"
    zinit self-update
    zinit update --all
    echo "✅ Zinit and all plugins updated"

    if ! dots_report_problems; then
        echo ""
        echo "❌ Dotfiles update finished with problems - see above"
        return 1
    fi

    echo "✅ Dotfiles update completed."
}

reload() {
    echo "🪚 Reloading zsh configuration"
    exec zsh
}

regenerate_completions() {
    echo "🔄 Regenerating zsh completion dumps"

    # Remove all zcompdump files
    local zcompdump_files=(~/.zcompdump*(N))
    if [[ ${#zcompdump_files[@]} -gt 0 ]]; then
        echo "🗑️ Removing existing completion dumps:"
        for file in "${zcompdump_files[@]}"; do
            echo "   - $(basename "$file")"
            rm -f "$file"
        done
    else
        echo "ℹ️ No existing completion dumps found"
    fi

    # Regenerate completions
    echo "🔨 Running compinit to regenerate completions..."
    autoload -Uz compinit
    compinit

    echo "✅ Completion dumps regenerated successfully"
    echo "💡 Reload your shell with 'exec zsh' or 'dots reload' to apply changes"
}

function dots() {
    case "$1" in
        reload|r)
            reload
            ;;
        doctor|d)
            doctor
            ;;
        update|u)
            update && reload
            ;;
        link|l)
            link_dots
            ;;
        cement)
            cement
            ;;
        uninstall)
            uninstall
            ;;
        regen-completions|rc)
            regenerate_completions
            ;;
        *)
            echo "Usage: dots {reload|doctor|link|update|cement|uninstall|regen-completions}"
            echo ""
            echo "Commands:"
            echo "  reload (r)             - Reload zsh configuration"
            echo "  regen-completions (rc) - Regenerate completion dumps"
            echo "  doctor (d)             - Check dotfiles health"
            echo "  link (l)               - Create any missing symlinks"
            echo "  update (u)             - Update dotfiles and plugins"
            echo "  cement                 - Lock current plugin versions"
            echo "  uninstall              - Remove dotfiles"
            return 1
            ;;
    esac
}

alias ...='dots'
alias .r='dots reload'
alias .d='dots doctor'
alias .u='dots update'
alias .l='dots link'
alias .rc='dots regen-completions'
