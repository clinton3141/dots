if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
else
    setopt PROMPT_SUBST

    local user_color="%F{blue}"
    local host_color="%F{magenta}"
    local dir_color="%F{cyan}"
    local git_color="%F{yellow}"
    local reset_color="%f"

    # Git status function
    git_prompt_info() {
        if git rev-parse --git-dir > /dev/null 2>&1; then
            local branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
            local git_status=""

            # Check for uncommitted changes
            if ! git diff --quiet 2>/dev/null; then
                git_status="*"
            fi

            # Check for staged changes
            if ! git diff --cached --quiet 2>/dev/null; then
                git_status="${git_status}+"
            fi

            # Check for untracked files
            if [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]; then
                git_status="${git_status}?"
            fi

            echo " on ${git_color}${branch}${git_status}${reset_color}"
        fi
    }

    # Set the prompt
    PROMPT='${user_color}%n${reset_color} at ${host_color}%m${reset_color} in ${dir_color}%~${reset_color}$(git_prompt_info)
%(?..%F{red}[%?] )%F{green}❯%f '
fi