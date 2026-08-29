#!/usr/bin/env sh
# Claude Code status line. Receives a JSON payload on stdin.

input=$(cat)

model=$(printf '%s' "$input" | jq -r '.model.display_name // "?"')
dir=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // ""')

dim=$(printf '\033[2m')
reset=$(printf '\033[0m')
cyan=$(printf '\033[36m')
yellow=$(printf '\033[33m')

out="${cyan}${model}${reset} ${dim}·${reset} $(basename "$dir")"

branch=$(git -C "$dir" --no-optional-locks branch --show-current 2>/dev/null)
if [ -n "$branch" ]; then
    if git -C "$dir" --no-optional-locks status --porcelain 2>/dev/null | grep -q .; then
        branch="${branch}*"
    fi
    out="${out} ${dim}·${reset} ${yellow}${branch}${reset}"
fi

printf '%s' "$out"
