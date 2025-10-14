# Trial Mode Implementation Summary

## Overview
A complete trial mode feature has been implemented for the dotfiles installation system, allowing users to safely test the configuration with full ability to uninstall and restore their original setup.

## Files Created/Modified

### New Files
1. **lib/trial.zsh** - Core trial mode library containing:
   - `is_trial_mode()` - Check if system is in trial mode
   - `init_trial()` - Initialize trial mode with backup directory and lock file
   - `record_backup()` - Record backed up files in trial.lock (JSON format)
   - `backup_existing()` - Backup files/symlinks/directories before replacement
   - `restore_trial()` - Restore all backed up files and remove trial mode
   - `finalize_trial()` - Remove backups and make installation permanent
   - `get_trial_status()` - Display trial mode information

2. **uninstall.zsh** - Standalone uninstall script
   - Interactive confirmation before uninstalling
   - Restores original dotfiles from backup
   - Only works in trial mode

3. **finalize.zsh** - Standalone finalization script
   - Interactive confirmation before finalizing
   - Removes backups and trial lock file
   - Makes installation permanent

### Modified Files
1. **install.zsh**
   - Added `--trial` flag support
   - Sources trial.zsh library
   - Prevents double trial installation
   - Backs up existing files before creating symlinks in trial mode
   - Shows appropriate messages for trial mode

2. **config/zsh/dots.zsh**
   - Sources trial.zsh library
   - Added trial status check in `doctor()` command
   - Added `finalize` command to dots utility
   - Added `uninstall` command to dots utility
   - Updated help text with new commands

3. **README.md**
   - Added trial mode installation instructions
   - Added usage examples for finalize/uninstall
   - Added "Trial Mode" section with detailed explanation
   - Updated tools documentation

## Data Structure

### Trial Lock File (~/.config/dots/trial.lock)
```json
{
  "version": "1.0",
  "timestamp": "2025-10-14T12:34:56Z",
  "backup_dir": "/Users/username/.config/dots/backup-20251014_123456",
  "backed_up_files": [
    {
      "original_path": "/Users/username/.zshrc",
      "backup_path": "/Users/username/.config/dots/backup-20251014_123456/.zshrc",
      "type": "file",
      "backed_up_at": "2025-10-14T12:34:57Z"
    }
  ]
}
```

## Usage Flow

### 1. Trial Installation
```bash
./install.zsh --trial
```
- Creates backup directory with timestamp
- Creates trial.lock file
- Backs up existing dotfiles
- Installs new dotfiles as symlinks

### 2. Testing Phase
```bash
dots doctor  # Check trial status
# Use the dotfiles normally...
```

### 3A. Finalize (Keep It)
```bash
dots finalize
# or
./finalize.zsh
```
- Removes backup directory
- Removes trial.lock file
- Installation becomes permanent

### 3B. Uninstall (Restore Original)
```bash
dots uninstall
# or
./uninstall.zsh
```
- Removes dotfiles symlinks
- Restores original files from backup
- Removes backup directory and trial.lock
- Reloads shell

## Safety Features

1. **Backup Integrity**
   - Preserves directory structure
   - Handles files, symlinks, and directories
   - Stores symlink targets separately

2. **Prevents Double Trial**
   - Cannot run `./install.zsh --trial` while already in trial mode
   - Must finalize or uninstall first

3. **Confirmation Prompts**
   - Both finalize and uninstall require user confirmation
   - Clear messaging about what will happen

4. **Status Visibility**
   - `dots doctor` shows trial mode status
   - Installation completion message shows trial mode info
   - Scripts provide helpful error messages

## Technical Details

### Python Dependency
The implementation uses Python 3 for JSON parsing to ensure reliability:
- Safer than text manipulation for JSON updates
- Built-in on macOS and most Unix systems
- Handles edge cases properly

### Backup Strategy
- Timestamped backup directories prevent collisions
- Complete file metadata preserved
- Symlinks handled specially (target path stored)

### Error Handling
- Functions return proper exit codes
- Error messages guide users to solutions
- Trial lock preserved on restoration errors

## Future Enhancements (Optional)

1. **Partial Uninstall**
   - Allow uninstalling specific dotfiles
   - Keep some configurations

2. **Backup Compression**
   - Compress backup directory to save space
   - Decompress on restore

3. **Multiple Backups**
   - Keep history of multiple backup points
   - Choose which backup to restore

4. **Dry Run Mode**
   - Preview what would be backed up
   - Show changes without making them
