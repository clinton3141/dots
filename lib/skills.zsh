#!/usr/bin/env zsh

# skills listed in skill-lock.json are fetched from their upstream sources; the
# hand-written ones in config/agents/skills are symlinked by lib/link.zsh
dots_restore_skills() {
    local root="${1:-$DOTS_ROOT}"
    local lock="$root/config/agents/skill-lock.json"

    if [[ ! -f "$lock" ]]; then
        DOTS_PROBLEMS+=("$lock is missing - no skills restored")
        return 0
    fi

    if ! command -v npx >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
        DOTS_PROBLEMS+=("npx and jq are required to restore agent skills - install them and run 'dots link'")
        return 0
    fi

    echo "📦 Restoring agent skills from skill-lock.json"

    # grouped by source so each upstream is fetched once
    local grouped
    if ! grouped="$(jq -r '.skills | to_entries | group_by(.value.source) | .[] | "\(.[0].value.source)\t\(map(.key) | join(" "))"' "$lock" 2>/dev/null)"; then
        DOTS_PROBLEMS+=("could not read $lock")
        return 0
    fi

    local -a sources=( ${(f)grouped} )

    local entry skill_source skill_names skill_name
    local -a skill_args
    for entry in $sources; do
        skill_source="${entry%%$'\t'*}"
        skill_names="${entry#*$'\t'}"
        echo "📦 Installing $skill_names from $skill_source"

        # --skill takes one name per flag; a comma-joined list is read as a
        # single literal skill name and matches nothing
        skill_args=()
        for skill_name in ${=skill_names}; do
            skill_args+=(--skill "$skill_name")
        done

        # </dev/null so npx can never stop for a prompt
        if command npx --yes skills add -g "$skill_source" "${skill_args[@]}" -y </dev/null; then
            echo "✅ $skill_source skills installed"
        else
            DOTS_PROBLEMS+=("failed to install skills from $skill_source")
        fi
    done

    return 0
}
