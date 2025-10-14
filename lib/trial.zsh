#!/usr/bin/env zsh

TRIAL_LOCK_FILE="$HOME/.config/dots/trial.lock"
TRIAL_BACKUP_DIR="$HOME/.config/dots/backup"

is_trial_mode() {
    [[ -f "$TRIAL_LOCK_FILE" ]]
}

get_backup_dir() {
    python3 <<PYTHON_SCRIPT
import json
with open("$TRIAL_LOCK_FILE", "r") as f:
    data = json.load(f)
print(data["backup_dir"])
PYTHON_SCRIPT
}

init_trial() {
    local timestamp=$(date +%Y%m%d_%H%M%S)

    command mkdir -p "$HOME/.config/dots"

    TRIAL_BACKUP_DIR="$HOME/.config/dots/backup-${timestamp}"
    command mkdir -p "$TRIAL_BACKUP_DIR"

    cat > "$TRIAL_LOCK_FILE" <<EOF
{
  "version": "1.0",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "backup_dir": "$TRIAL_BACKUP_DIR",
  "backed_up_files": []
}
EOF

    echo "🧪 Trial mode initialized"
    echo "📦 Backup directory: $TRIAL_BACKUP_DIR"
}

record_backup() {
    local original_path="$1"
    local backup_path="$2"
    local file_type="$3"

    if [[ ! -f "$TRIAL_LOCK_FILE" ]]; then
        echo "❌ Trial lock file not found"
        return 1
    fi

    local new_entry=$(cat <<EOF
{
  "original_path": "$original_path",
  "backup_path": "$backup_path",
  "type": "$file_type",
  "backed_up_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
)

    python3 <<PYTHON_SCRIPT
import json
import sys

try:
    with open("$TRIAL_LOCK_FILE", "r") as f:
        data = json.load(f)

    new_entry = $new_entry
    data["backed_up_files"].append(new_entry)

    with open("$TRIAL_LOCK_FILE", "w") as f:
        json.dump(data, f, indent=2)
except Exception as e:
    print(f"Error updating trial lock: {e}", file=sys.stderr)
    sys.exit(1)
PYTHON_SCRIPT
}

backup_existing() {
    local target="$1"

    if [[ ! -e "$target" ]] && [[ ! -L "$target" ]]; then
        return 0
    fi

    local backup_dir=$(get_backup_dir)
    local rel_path="${target#$HOME/}"
    local backup_path="$backup_dir/$rel_path"
    local backup_parent="$(dirname "$backup_path")"

    command mkdir -p "$backup_parent"

    local file_type
    if [[ -L "$target" ]]; then
        file_type="symlink"
        local link_target="$(readlink "$target")"
        echo "$link_target" > "${backup_path}.symlink_target"
        echo "📦 Backed up symlink: $target -> $link_target"
    elif [[ -d "$target" ]]; then
        file_type="directory"
        command cp -R "$target" "$backup_path"
        echo "📦 Backed up directory: $target"
    else
        file_type="file"
        command cp "$target" "$backup_path"
        echo "📦 Backed up file: $target"
    fi

    record_backup "$target" "$backup_path" "$file_type"
    command rm -rf "$target"
}

restore_trial() {
    if [[ ! -f "$TRIAL_LOCK_FILE" ]]; then
        echo "❌ Not in trial mode"
        return 1
    fi

    echo "🔄 Restoring backed up files..."

    python3 <<'PYTHON_SCRIPT'
import json
import os
import shutil
import sys

try:
    trial_lock_file = os.path.expandvars("$HOME/.config/dots/trial.lock")
    with open(trial_lock_file, "r") as f:
        data = json.load(f)

    backed_up_files = data.get("backed_up_files", [])

    for entry in reversed(backed_up_files):
        original_path = entry["original_path"]
        backup_path = entry["backup_path"]
        file_type = entry["type"]

        if os.path.exists(original_path) or os.path.islink(original_path):
            if os.path.islink(original_path) or os.path.isfile(original_path):
                os.remove(original_path)
            elif os.path.isdir(original_path):
                shutil.rmtree(original_path)

        if file_type == "symlink":
            symlink_target_file = backup_path + ".symlink_target"
            if os.path.exists(symlink_target_file):
                with open(symlink_target_file, "r") as f:
                    link_target = f.read().strip()
                os.symlink(link_target, original_path)
                print(f"✅ Restored symlink: {original_path} -> {link_target}")
        elif file_type == "directory":
            if os.path.exists(backup_path):
                shutil.copytree(backup_path, original_path)
                print(f"✅ Restored directory: {original_path}")
        elif file_type == "file":
            if os.path.exists(backup_path):
                shutil.copy2(backup_path, original_path)
                print(f"✅ Restored file: {original_path}")

    print(f"\n🧹 Cleaning up backup directory: {data['backup_dir']}")
    if os.path.exists(data["backup_dir"]):
        shutil.rmtree(data["backup_dir"])

except Exception as e:
    print(f"❌ Error during restoration: {e}", file=sys.stderr)
    sys.exit(1)
PYTHON_SCRIPT

    if [[ $? -eq 0 ]]; then
        command rm -f "$TRIAL_LOCK_FILE"
        echo "✅ Trial mode removed and all files restored"
        return 0
    else
        echo "❌ Restoration failed. Trial lock file preserved."
        return 1
    fi
}

finalize_trial() {
    if [[ ! -f "$TRIAL_LOCK_FILE" ]]; then
        echo "❌ Not in trial mode"
        return 1
    fi

    echo "🎉 Cementing your choice..."

    local backup_dir=$(get_backup_dir)

    if [[ -d "$backup_dir" ]]; then
        echo "🧹 Removing backup directory: $backup_dir"
        command rm -rf "$backup_dir"
    fi

    command rm -f "$TRIAL_LOCK_FILE"
    echo "✅ Trial complete. Dotfiles installation is now permanent."
}

get_trial_status() {
    if [[ ! -f "$TRIAL_LOCK_FILE" ]]; then
        return 1
    fi

    python3 <<'PYTHON_SCRIPT'
import json
from datetime import datetime
import os

trial_lock_file = os.path.expandvars("$HOME/.config/dots/trial.lock")
with open(trial_lock_file, "r") as f:
    data = json.load(f)

print(f"📋 Trial Mode Status:")
print(f"   Started: {data['timestamp']}")
print(f"   Backup location: {data['backup_dir']}")
print(f"   Files backed up: {len(data['backed_up_files'])}")
PYTHON_SCRIPT
}
