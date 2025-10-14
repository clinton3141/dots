#!/usr/bin/env zsh
# Trial mode management library for dotfiles installation

TRIAL_LOCK_FILE="$HOME/.config/dots/trial.lock"
TRIAL_BACKUP_DIR="$HOME/.config/dots/backup"

# Check if system is in trial mode
is_trial_mode() {
    [[ -f "$TRIAL_LOCK_FILE" ]]
}

# Initialize trial mode
init_trial() {
    local timestamp=$(date +%Y%m%d_%H%M%S)

    # Ensure dots config directory exists
    command mkdir -p "$HOME/.config/dots"

    # Create backup directory with timestamp
    TRIAL_BACKUP_DIR="$HOME/.config/dots/backup-${timestamp}"
    command mkdir -p "$TRIAL_BACKUP_DIR"

    # Initialize trial lock file with metadata
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

# Add a backed up file to the trial lock
record_backup() {
    local original_path="$1"
    local backup_path="$2"
    local file_type="$3"  # "file", "symlink", or "directory"

    if [[ ! -f "$TRIAL_LOCK_FILE" ]]; then
        echo "❌ Error: Trial lock file not found"
        return 1
    fi

    # Read existing lock file
    local lock_content=$(cat "$TRIAL_LOCK_FILE")

    # Create new entry
    local new_entry=$(cat <<EOF
{
  "original_path": "$original_path",
  "backup_path": "$backup_path",
  "type": "$file_type",
  "backed_up_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
)

    # Use python to properly update JSON (more reliable than text manipulation)
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

# Backup a file/symlink/directory before replacing it
backup_existing() {
    local target="$1"

    if [[ ! -e "$target" ]] && [[ ! -L "$target" ]]; then
        # Target doesn't exist, nothing to backup
        return 0
    fi

    # Get backup directory from trial lock
    local backup_dir=$(python3 <<PYTHON_SCRIPT
import json
with open("$TRIAL_LOCK_FILE", "r") as f:
    data = json.load(f)
print(data["backup_dir"])
PYTHON_SCRIPT
)

    # Determine relative path from HOME
    local rel_path="${target#$HOME/}"
    local backup_path="$backup_dir/$rel_path"
    local backup_parent="$(dirname "$backup_path")"

    # Create parent directory in backup location
    command mkdir -p "$backup_parent"

    # Determine type and backup
    local file_type
    if [[ -L "$target" ]]; then
        file_type="symlink"
        # For symlinks, save both the link and its target
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

    # Record in trial lock
    record_backup "$target" "$backup_path" "$file_type"

    # Remove original
    command rm -rf "$target"

    return 0
}

# Restore all backed up files and remove trial mode
restore_trial() {
    if [[ ! -f "$TRIAL_LOCK_FILE" ]]; then
        echo "❌ Error: Not in trial mode (trial lock file not found)"
        return 1
    fi

    echo "🔄 Restoring backed up files..."

    # Read backed up files using python for reliable JSON parsing
    python3 <<PYTHON_SCRIPT
import json
import os
import shutil
import sys

try:
    with open("$TRIAL_LOCK_FILE", "r") as f:
        data = json.load(f)

    backed_up_files = data.get("backed_up_files", [])

    # Reverse order to restore properly
    for entry in reversed(backed_up_files):
        original_path = entry["original_path"]
        backup_path = entry["backup_path"]
        file_type = entry["type"]

        # Remove current symlink/file if it exists
        if os.path.exists(original_path) or os.path.islink(original_path):
            if os.path.islink(original_path) or os.path.isfile(original_path):
                os.remove(original_path)
            elif os.path.isdir(original_path):
                shutil.rmtree(original_path)

        # Restore from backup
        if file_type == "symlink":
            # Restore symlink
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

    print(f"\\n🧹 Cleaning up backup directory: {data['backup_dir']}")
    if os.path.exists(data["backup_dir"]):
        shutil.rmtree(data["backup_dir"])

except Exception as e:
    print(f"❌ Error during restoration: {e}", file=sys.stderr)
    sys.exit(1)
PYTHON_SCRIPT

    if [[ $? -eq 0 ]]; then
        # Remove trial lock file
        command rm -f "$TRIAL_LOCK_FILE"
        echo "✅ Trial mode removed and all files restored"
        return 0
    else
        echo "❌ Error during restoration. Trial lock file preserved."
        return 1
    fi
}

# Finalize trial mode (remove backups and lock file)
finalize_trial() {
    if [[ ! -f "$TRIAL_LOCK_FILE" ]]; then
        echo "❌ Error: Not in trial mode (trial lock file not found)"
        return 1
    fi

    echo "🎉 Finalizing trial mode..."

    # Get backup directory
    local backup_dir=$(python3 <<PYTHON_SCRIPT
import json
with open("$TRIAL_LOCK_FILE", "r") as f:
    data = json.load(f)
print(data["backup_dir"])
PYTHON_SCRIPT
)

    # Remove backup directory
    if [[ -d "$backup_dir" ]]; then
        echo "🧹 Removing backup directory: $backup_dir"
        command rm -rf "$backup_dir"
    fi

    # Remove trial lock file
    command rm -f "$TRIAL_LOCK_FILE"

    echo "✅ Trial finalized! Dotfiles installation is now permanent."
    return 0
}

# Get trial status information
get_trial_status() {
    if [[ ! -f "$TRIAL_LOCK_FILE" ]]; then
        return 1
    fi

    python3 <<PYTHON_SCRIPT
import json
from datetime import datetime

with open("$TRIAL_LOCK_FILE", "r") as f:
    data = json.load(f)

print(f"📋 Trial Mode Status:")
print(f"   Started: {data['timestamp']}")
print(f"   Backup location: {data['backup_dir']}")
print(f"   Files backed up: {len(data['backed_up_files'])}")
PYTHON_SCRIPT
}
