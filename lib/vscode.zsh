#!/usr/bin/env zsh

# without this, the Claude Code harness inside VS Code ignores ~/.claude/CLAUDE.md
DOTS_VSCODE_SETTING="chat.useClaudeMdFile"

# VS Code owns this file and keeps unrelated user settings in it, so the setting
# is merged in rather than the file being symlinked
dots_vscode_settings_file() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        print -r -- "$HOME/Library/Application Support/Code/User/settings.json"
    else
        print -r -- "$HOME/.config/Code/User/settings.json"
    fi
}

# prints the current value, or "unset"; empty output means it could not be read
dots_vscode_setting_value() {
    local file="$(dots_vscode_settings_file)"

    [[ -f "$file" ]] || return 1
    command -v jq >/dev/null 2>&1 || return 1

    local value
    # settings.json is JSONC, so a file with comments in it will not parse
    value="$(jq -r --arg key "$DOTS_VSCODE_SETTING" 'if has($key) then .[$key] else "unset" end' "$file" 2>/dev/null)" || return 1

    print -r -- "$value"
}

dots_enable_vscode_claude_md() {
    local file="$(dots_vscode_settings_file)"

    if [[ ! -d "${file:h}" ]]; then
        echo "ℹ️  VS Code is not installed - skipping $DOTS_VSCODE_SETTING"
        return 0
    fi

    # trial mode restores by replacing whole files, which would lose every other
    # VS Code setting on uninstall; leave the file alone until the trial ends
    if [[ "$TRIAL_MODE" == true ]] || { whence -w is_trial_mode >/dev/null && is_trial_mode }; then
        echo "🧪 trial mode - not touching VS Code settings"
        echo "   set \"$DOTS_VSCODE_SETTING\": true by hand to use ~/.claude/CLAUDE.md in VS Code"
        return 0
    fi

    if ! command -v jq >/dev/null 2>&1; then
        DOTS_PROBLEMS+=("jq is required to set \"$DOTS_VSCODE_SETTING\" in $file")
        return 0
    fi

    if [[ ! -f "$file" ]]; then
        echo "🔧 Creating $file"
        printf '{\n  "%s": true\n}\n' "$DOTS_VSCODE_SETTING" > "$file"
        echo "✅ Enabled $DOTS_VSCODE_SETTING in VS Code"
        return 0
    fi

    local current
    if ! current="$(dots_vscode_setting_value)"; then
        DOTS_PROBLEMS+=("could not parse $file (comments?) - set \"$DOTS_VSCODE_SETTING\": true by hand")
        return 0
    fi

    case "$current" in
        true)
            echo "✅ $DOTS_VSCODE_SETTING is already enabled in VS Code"
            return 0
            ;;
        false)
            # an explicit opt-out is the user's call, not ours to overwrite
            DOTS_PROBLEMS+=("\"$DOTS_VSCODE_SETTING\" is set to false in $file - left alone")
            return 0
            ;;
    esac

    local tmp="${file}.dots.tmp"
    if jq --arg key "$DOTS_VSCODE_SETTING" '.[$key] = true' "$file" > "$tmp" && command mv "$tmp" "$file"; then
        echo "✅ Enabled $DOTS_VSCODE_SETTING in VS Code"
    else
        command rm -f "$tmp"
        DOTS_PROBLEMS+=("failed to write $file")
    fi

    return 0
}
