#!/usr/bin/env zsh

# self-locating: this file is sourced by install.zsh, by config/zsh/dots.zsh and
# by tests, none of which agree on what $DOTFILES_DIR holds at source time
DOTS_ROOT="${${(%):-%x}:A:h:h}"

# anything the run could not do unattended, collected for an end-of-run summary
typeset -ga DOTS_PROBLEMS=()

# directories that must exist before any link is made; ~/.agents/skills cannot
# itself be a symlink because the skills CLI installs into it alongside ours
dots_link_dirs() {
    print -rl -- \
        "$HOME/.config" \
        "$HOME/.config/dots" \
        "$HOME/.claude" \
        "$HOME/.agents" \
        "$HOME/.agents/skills" \
        "$HOME/.copilot/instructions"
}

# emits "source<TAB>target" lines - the single source of truth shared by
# install, `dots link`, `dots update` and `dots doctor`
dots_link_map() {
    local root="${1:-$DOTS_ROOT}"
    local file skill

    for file in zshrc tmux.conf; do
        print -r -- "$root/dots/$file"$'\t'"$HOME/.$file"
    done

    for file in zsh tmux zsh-abbr starship.toml; do
        print -r -- "$root/config/$file"$'\t'"$HOME/.config/$file"
    done

    print -r -- "$root/custom"$'\t'"$HOME/.config/dots/custom"

    for file in settings.json statusline.sh; do
        print -r -- "$root/config/claude/$file"$'\t'"$HOME/.claude/$file"
    done

    # one source of truth, read by Claude Code as memory and by Copilot's
    # default harness as an instructions file
    print -r -- "$root/config/agents/agreements.md"$'\t'"$HOME/.claude/CLAUDE.md"
    print -r -- "$root/config/agents/agreements.md"$'\t'"$HOME/.copilot/instructions/agreements.instructions.md"

    print -r -- "$root/config/agents/skill-lock.json"$'\t'"$HOME/.agents/.skill-lock.json"

    for skill in "$root"/config/agents/skills/*(/N); do
        print -r -- "$skill"$'\t'"$HOME/.agents/skills/${skill:t}"
    done
}

# 0 already correct, 1 nothing there, 2 dangling symlink, 3 something else
dots_check_target() {
    local target="$1"
    local expected_source="$2"

    if [[ -L "$target" ]]; then
        [[ "$(readlink "$target")" == "$expected_source" ]] && return 0
        # points nowhere, so there is nothing to lose by replacing it - this is
        # what every link looks like after the dots checkout is moved
        [[ -e "$target" ]] || return 2
        return 3
    fi

    [[ -e "$target" ]] && return 3
    return 1
}

dots_create_symlink() {
    local source="$1"
    local target="$2"

    local result=0
    dots_check_target "$target" "$source" || result=$?

    case $result in
        0)
            echo "✅ $target is correctly linked"
            ;;
        1)
            echo "🔗 Creating $target"
            command ln -s "$source" "$target"
            echo "✅ $target created successfully"
            ;;
        2)
            echo "🔧 $target is a broken symlink - relinking"
            command rm -f "$target"
            command ln -s "$source" "$target"
            echo "✅ $target created successfully"
            ;;
        3)
            if [[ "$TRIAL_MODE" == true ]]; then
                echo "📦 $target exists - backing up before replacing"
                backup_existing "$target"
                echo "🔗 Creating $target"
                command ln -s "$source" "$target"
                echo "✅ $target created successfully"
            else
                echo "⚠️  $target exists but is not linked to $source"
                DOTS_PROBLEMS+=("$target is in the way - move it aside and re-run, or install with --trial to have it backed up")
            fi
            ;;
    esac
}

dots_ensure_dirs() {
    local dir
    for dir in ${(f)"$(dots_link_dirs)"}; do
        if [[ ! -d "$dir" ]]; then
            echo "📁 Creating $dir"
            command mkdir -p "$dir"
        fi
    done
}

dots_link_all() {
    dots_ensure_dirs

    local entry
    # a for loop, not `dots_link_map | while read`: zsh runs every stage of a
    # pipeline in a subshell, which would discard appends to $DOTS_PROBLEMS
    for entry in ${(f)"$(dots_link_map)"}; do
        dots_create_symlink "${entry%%$'\t'*}" "${entry#*$'\t'}"
    done

    return 0
}

# non-zero when anything was skipped, so callers can fail loudly
dots_report_problems() {
    (( ${#DOTS_PROBLEMS} )) || return 0

    echo ""
    echo "⚠️  ${#DOTS_PROBLEMS} item(s) need attention:"
    local problem
    for problem in "${DOTS_PROBLEMS[@]}"; do
        echo "   - $problem"
    done

    return 1
}
