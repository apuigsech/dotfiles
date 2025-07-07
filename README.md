# Dotfiles

A comprehensive dotfiles setup using [Dotbot](https://github.com/anishathalye/dotbot) for easy installation and management across different systems.

## Features

- **Unified Command Interface**: Single `./dotfiles` command with multiple subcommands
- **Plugin-based Architecture**: Modular configuration system with enhanced plugin support
- **Cross-platform Support**: Works on macOS and Linux with platform-specific configurations
- **Profile System**: Environment-specific configurations and settings
- **Package Management**: Automated brew package installation with cask support
- **Shell Configuration**: Zsh with Oh My Zsh integration and enhanced shell utilities
- **Development Tools**: Git, direnv, hammerspoon, Cursor IDE, and comprehensive dev setup
- **Configuration Management**: Centralized configuration with `config/dotfiles.conf`
- **Advanced Logging**: Comprehensive logging with rotation and debug modes
- **Error Handling**: Robust error handling with strict mode and fail-fast options
- **Status Monitoring**: Built-in status checking and health monitoring
- **Uninstall Support**: Complete uninstall functionality for plugins and configurations
- **macOS Optimization**: Comprehensive macOS defaults and system optimization

## Quick Start

```bash
git clone https://github.com/apuigsech/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Basic initialization (links essential files)
./dotfiles init

# Install all plugins (comprehensive setup)
./dotfiles install --all

# Check installation status
./dotfiles status
```

## Command Interface

The dotfiles system provides a unified command interface:

```bash
./dotfiles <command> [options]
```

### Available Commands

#### `init` - Basic Initialization
Performs basic dotfiles initialization using dotbot:
```bash
./dotfiles init                    # Basic setup
./dotfiles init --verbose          # With detailed output
```

#### `install` - Plugin Installation
Install specific plugins or all plugins:
```bash
./dotfiles install --all           # Install all plugins
./dotfiles install brew zsh        # Install specific plugins
./dotfiles install --all --debug   # Install with debug output
```

#### `uninstall` - Plugin Removal
Remove specific plugins or all plugins:
```bash
./dotfiles uninstall --all         # Remove all plugins
./dotfiles uninstall brew zsh      # Remove specific plugins
./dotfiles uninstall --all --dry-run # Preview what would be removed
```

#### `status` - Installation Status
Check current installation status:
```bash
./dotfiles status                  # Basic status check
./dotfiles status --verbose        # Detailed status information
```

#### `help` - Help System
Get help for commands:
```bash
./dotfiles help                    # General help
./dotfiles help install            # Command-specific help
```

### Global Options

- `--debug`: Enable debug mode with verbose output
- `--strict`: Enable strict mode (exit on any error)
- `--fail-fast`: Exit immediately on first error
- `--verbose`: Enable verbose logging
- `--quiet`: Only show errors

## Configuration System

### Central Configuration
The system uses `config/dotfiles.conf` for centralized configuration:

```bash
# Logging configuration
log.level=info
log.colors=true
log.rotation=10

# Error handling
error.strict=false
error.fail_fast=false

# Security settings
security.strict=true
security.max_file_size=104857600

# Performance settings
performance.parallel=true
performance.timeout=300

# Plugin settings
plugins.enabled=brew,shell,zsh,direnv,hammerspoon,configs,bluereset,renicer,cursor,macos-defaults
```

### Environment Variables
Override configuration with environment variables:
```bash
export DOTFILES_DEBUG=true
export DOTFILES_STRICT=true
export DOTFILES_LOG_LEVEL=debug
```

## Structure

```
dotfiles/
├── dotfiles              # Main command interface
├── bootstap              # Legacy bootstrap script
├── install.conf.yaml     # Basic dotbot configuration
├── config/               # Configuration files
│   └── dotfiles.conf     # Main configuration
├── profiles/             # Environment-specific configurations
│   ├── macos            # macOS-specific settings
│   └── linux            # Linux-specific settings
├── plugins/              # Enhanced plugin system
│   ├── brew/            # Homebrew package management
│   ├── configs/         # Configuration files (.gitconfig, etc.)
│   ├── shell/           # Shell configuration
│   ├── zsh/             # Zsh-specific setup
│   ├── direnv/          # Directory environment management
│   ├── hammerspoon/     # macOS automation (Hammerspoon)
│   ├── cursor/          # Cursor IDE configuration
│   ├── macos-defaults/  # macOS system defaults
│   ├── bluereset/       # Bluetooth reset utility
│   └── renicer/         # Process priority management
├── files/               # Actual configuration files
├── lib/                 # Enhanced utility libraries
│   ├── utils            # Common utility functions
│   ├── logger           # Advanced logging system
│   ├── errors           # Error handling utilities
│   ├── progress         # Progress tracking
│   ├── uninstall        # Uninstall functionality
│   ├── dotbot           # Dotbot wrapper functions
│   └── brew             # Homebrew helper functions
├── cache/               # Cache directory
├── logs/                # Log files with rotation
└── dotbot/              # Dotbot submodule
```

## Plugins

The dotfiles system includes comprehensive plugin support:

### Core Plugins

- **brew**: Manages Homebrew packages and cask applications with auto-update
- **shell**: Enhanced shell configuration with aliases, environment variables, and paths
- **zsh**: Zsh-specific configuration with Oh My Zsh integration and themes
- **configs**: System configuration files (Git, wget, etc.) with templates

### Development Plugins

- **cursor**: Complete Cursor IDE setup with settings, keybindings, and extensions
- **direnv**: Automatic environment variable loading per directory
- **hammerspoon**: macOS automation and window management with Lua scripts

### System Plugins

- **macos-defaults**: Comprehensive macOS system defaults and optimizations
- **bluereset**: Bluetooth reset utility for macOS connectivity issues
- **renicer**: Process priority management tool for system optimization

### Plugin Features

Each plugin supports:
- **Individual installation**: Install specific plugins only
- **Configuration management**: Centralized configuration files
- **Status checking**: Individual plugin health monitoring
- **Uninstall support**: Complete removal with cleanup
- **Documentation**: Comprehensive README files

## Installation Process

The enhanced installation process provides multiple options:

### Basic Setup (Recommended for new users)
```bash
./dotfiles init
```

### Full Setup (Comprehensive installation)
```bash
./dotfiles install --all
```

### Custom Setup (Specific plugins)
```bash
./dotfiles install brew zsh cursor
```

## Package Management

The brew plugin provides comprehensive package management:

### Packages Installed
- **Development Tools**: git, docker, docker-compose, httpie, jq, yq
- **Shell Utilities**: coreutils, eza, fzf, tree, tldr, bat, ripgrep
- **System Tools**: blueutil, gnupg, direnv, mas, mackup
- **Programming Languages**: node, python, go, rust
- **Applications**: Various cask applications for development and productivity

### Cask Applications
- **Development**: Cursor, Docker Desktop, Postman, TablePlus
- **Productivity**: Alfred, Raycast, CleanMyMac, Bartender
- **Media**: VLC, IINA, Spotify, Discord
- **Utilities**: The Unarchiver, AppCleaner, Finder Path

## Configuration Files

Enhanced configuration management through multiple plugins:

### Core Configurations
- `.gitconfig` - Git configuration with aliases and settings
- `.gitignore` - Global Git ignore patterns
- `.zshrc` - Zsh configuration with Oh My Zsh
- `.direnvrc` - Direnv configuration and utilities

### Application Configurations
- **Cursor IDE**: Complete settings, keybindings, and extensions
- **Hammerspoon**: Lua scripts for macOS automation
- **Terminal**: Enhanced terminal configuration

## macOS System Optimization

The `macos-defaults` plugin provides comprehensive system optimization:

### System Settings
- **UI/UX Enhancements**: Disable boot sound, reduce transparency, fast animations
- **Input Optimization**: Trackpad tap-to-click, fast key repeat, full keyboard access
- **Energy Management**: Optimized sleep settings, prevent hibernation

### Finder Enhancements
- **Visibility**: Show all file extensions, hidden files, path bar
- **Behavior**: Disable warnings, search current folder, folders on top
- **Performance**: No .DS_Store on network volumes

### Dock Configuration
- **Appearance**: Customizable icon size, scale effects, indicators
- **Hot Corners**: Mission Control, Desktop, Screen Saver
- **Behavior**: Auto-hide, fast animations

### Application Defaults
- **Safari**: Privacy-focused, developer-friendly settings
- **Mail**: Disable animations, threading, keyboard shortcuts
- **Terminal**: UTF-8 encoding, secure keyboard entry

## Shell Configuration

Enhanced shell setup with comprehensive features:

### Zsh Configuration
- **Oh My Zsh Integration**: With Powerlevel10k theme
- **Plugin System**: Git, docker, kubectl, and custom plugins
- **Aliases**: Comprehensive command shortcuts
- **Functions**: Custom shell functions and utilities

### Environment Management
- **Path Management**: Automatic PATH configuration
- **Environment Variables**: System-wide environment setup
- **Direnv Integration**: Per-directory environment variables

## Development Environment

Complete development environment setup:

### Cursor IDE
- **Settings**: Comprehensive editor configuration
- **Keybindings**: Optimized keyboard shortcuts including AI features
- **Extensions**: Curated list of development extensions
- **AI Integration**: Cursor-specific AI features and workflows

### Git Configuration
- **Aliases**: Comprehensive git aliases for productivity
- **Settings**: Optimized git configuration
- **Hooks**: Pre-commit hooks and automation

### Docker Integration
- **Docker Desktop**: Automated installation and configuration
- **Docker Compose**: Enhanced compose workflows
- **Container Management**: Utilities and aliases

## Customization

### Adding New Plugins

1. Create plugin directory:
```bash
mkdir plugins/my-plugin
```

2. Add configuration files:
```bash
# Plugin setup
echo '#!/bin/bash' > plugins/my-plugin/setup.sh
echo '- link:' > plugins/my-plugin/setup.dotbot
```

3. Update plugin list:
```bash
# Add to DOTFILES_PLUGINS in dotfiles script
```

### Custom Configuration

1. **Override settings**: Edit `config/dotfiles.conf`
2. **Environment variables**: Use `DOTFILES_*` environment variables
3. **Plugin configuration**: Edit individual plugin files
4. **Profile-specific**: Use `profiles/` directory for environment-specific settings

## Logging and Monitoring

### Enhanced Logging
- **Log Levels**: Debug, info, warn, error
- **Log Rotation**: Automatic log file rotation
- **Colored Output**: Enhanced readability
- **Debug Mode**: Comprehensive debugging information

### Status Monitoring
```bash
./dotfiles status --verbose
```

Provides:
- **Repository Status**: Git repository health
- **Plugin Status**: Individual plugin installation status
- **Link Status**: Symlink integrity checking
- **System Health**: Overall system configuration status

## Error Handling

### Modes
- **Normal Mode**: Continue on errors with warnings
- **Strict Mode**: Exit on any error
- **Fail-Fast Mode**: Exit immediately on first error
- **Debug Mode**: Comprehensive error information

### Error Recovery
- **Automatic Retry**: Configurable retry attempts
- **Rollback Support**: Automatic rollback on failures
- **Manual Recovery**: Detailed error messages and recovery steps

## Uninstall Support

Complete uninstall functionality:

### Plugin Uninstall
```bash
./dotfiles uninstall plugin-name
```

### Full Uninstall
```bash
./dotfiles uninstall --all
```

### Dry Run
```bash
./dotfiles uninstall --all --dry-run
```

Features:
- **Symlink Removal**: Automatic symlink cleanup
- **Directory Cleanup**: Remove empty directories
- **Configuration Backup**: Backup before removal
- **Selective Removal**: Remove specific plugins only

## Requirements

- **Git**: For cloning and submodule management
- **Bash/Zsh**: Compatible shell environment
- **macOS or Linux**: Supported operating systems
- **Python 3**: For Dotbot functionality
- **Homebrew**: For package management (auto-installed on macOS)

## Troubleshooting

### Common Issues

#### Permission Issues
```bash
chmod +x dotfiles
```

#### Submodule Issues
```bash
git submodule update --init --recursive
```

#### Plugin-Specific Issues
```bash
./dotfiles status --verbose
```

### Debug Mode
```bash
./dotfiles install --all --debug
```

### Log Files
Check log files in `logs/` directory for detailed error information.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `./dotfiles status`
5. Submit a pull request

## License

This project is open source and available under the [MIT License](LICENSE).

## Acknowledgments

- [Dotbot](https://github.com/anishathalye/dotbot) - The dotfiles installer framework
- [Oh My Zsh](https://ohmyz.sh/) - Zsh configuration framework
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) - Zsh theme
- [Cursor](https://cursor.sh/) - AI-powered code editor
- [Hammerspoon](https://www.hammerspoon.org/) - macOS automation tool 