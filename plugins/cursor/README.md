# Cursor Plugin

This plugin configures [Cursor](https://cursor.sh/) IDE with a comprehensive set of settings, keybindings, and recommended extensions for modern development workflows.

## What it does

The cursor plugin sets up:

- **Global Settings**: Comprehensive VSCode-compatible settings for editor behavior, formatting, git integration, and more
- **Keybindings**: Optimized keyboard shortcuts for productivity, including Cursor-specific AI features
- **Extensions**: Curated list of recommended extensions for various programming languages and workflows
- **Directory Structure**: Proper Cursor configuration directory structure

## Files

- `settings.json` - Complete editor settings configuration
- `keybindings.json` - Keyboard shortcuts and hotkeys
- `extensions.json` - Recommended and unwanted extensions
- `setup.dotbot` - Dotbot configuration for linking files

## Features

### Editor Settings
- Modern font configuration with ligatures
- Optimized formatting and linting
- Git integration with decorations
- Terminal integration with zsh
- Language-specific formatting rules
- File associations and exclusions

### Keybindings
- File management shortcuts
- Navigation and editor management
- Code editing and formatting
- Search and replace operations
- Terminal and debug shortcuts
- Git operations
- **Cursor AI Features**:
  - `Cmd+K` - Quick Edit
  - `Cmd+L` - Open Chat
  - `Cmd+I` - Open Composer
  - `Cmd+Alt+K` - Quick Edit with Selection
  - `Cmd+Alt+L` - Add Selection to Chat
  - `Cmd+Alt+I` - Add Selection to Composer

### Extensions
- Essential development tools (Prettier, ESLint, etc.)
- Language support (Python, Go, Rust, TypeScript, etc.)
- Git integration (GitLens, Git History, etc.)
- Productivity tools (Better Comments, TODO Tree, etc.)
- Themes and icons
- DevOps and cloud tools
- Testing frameworks

## Installation

The plugin is automatically installed when running the bootstrap script:

```bash
./bootstap
```

Or install just the cursor plugin:

```bash
cd plugins/cursor
../../dotbot/bin/dotbot -c setup.dotbot
```

## Configuration Location

Files are linked to:
- `~/Library/Application Support/Cursor/User/settings.json`
- `~/Library/Application Support/Cursor/User/keybindings.json`
- `~/Library/Application Support/Cursor/User/extensions.json`

## Customization

To customize the configuration:

1. Edit the JSON files in this directory
2. Run the bootstrap script or dotbot configuration to apply changes
3. Restart Cursor to see the changes

## Notes

- This plugin is designed for macOS. The paths may need adjustment for other platforms.
- The configuration is compatible with VSCode, so you can use the same settings across both editors.
- Some extensions may require additional setup or API keys.
- The settings include Cursor-specific configurations that may not work in standard VSCode.

## Troubleshooting

If Cursor doesn't pick up the settings:

1. Ensure Cursor is completely closed
2. Check that the files are properly linked in the Application Support directory
3. Restart Cursor
4. Check Cursor's settings to verify they were applied

For extension installation issues:
1. Open Cursor
2. Go to Extensions (Cmd+Shift+X)
3. Check if extensions are being installed automatically
4. Manually install any missing extensions if needed 