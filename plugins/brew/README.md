# Brew Plugin

This plugin manages Homebrew installation and package management for macOS. It automatically installs Homebrew if not present and installs a curated list of command-line tools and GUI applications.

## What it does

The brew plugin:

- Installs Homebrew package manager if not already installed
- Installs essential command-line tools from `packages.lst`
- Installs GUI applications (casks) from `packages-cask.lst`
- Provides a foundation for other plugins that depend on Homebrew packages

## Files

- `setup.sh` - Main installation script
- `packages.lst` - List of command-line tools to install
- `packages-cask.lst` - List of GUI applications to install

## Features

### Automatic Homebrew Setup
- Detects if Homebrew is already installed
- Downloads and installs Homebrew if missing
- Validates installation and provides error handling

### Package Management
- Installs curated list of essential development tools
- Installs popular GUI applications
- Skips already installed packages for efficiency
- Provides logging for installation status

## Installed Packages

### Command-line Tools (`packages.lst`)
- `blueutil` - Bluetooth utility for macOS
- `coreutils` - GNU core utilities
- `direnv` - Environment variable manager
- `docker` - Container platform
- `docker-compose` - Docker orchestration tool
- `eza` - Modern replacement for `ls`
- `fzf` - Fuzzy finder
- `git-delta` - Syntax-highlighting pager for git
- `gnupg` - GNU Privacy Guard
- `gnutls` - Secure communications library
- `httpie` - User-friendly HTTP client
- `tldr` - Simplified man pages
- `tree` - Directory tree viewer
- `zsh` - Z shell

### GUI Applications (`packages-cask.lst`)
- `1password` - Password manager
- `arc` - Modern web browser
- `google-chrome` - Web browser
- `gpg-suite` - GPG tools for macOS
- `hammerspoon` - macOS automation tool
- `iterm2` - Terminal emulator
- `slack` - Team communication
- `spotify` - Music streaming
- `telegram` - Messaging app
- `tunnelblick` - VPN client
- `visual-studio-code` - Code editor
- `vlc` - Media player

## Installation

The plugin is automatically installed when running the bootstrap script:

```bash
./bootstap
```

Or install just the brew plugin:

```bash
cd plugins/brew
bash setup.sh
```

## Customization

### Adding Packages

To add new command-line tools:
1. Edit `packages.lst`
2. Add one package name per line
3. Run the bootstrap script or setup.sh

To add new GUI applications:
1. Edit `packages-cask.lst`
2. Add one cask name per line
3. Run the bootstrap script or setup.sh

### Example: Adding a New Package

```bash
# Add to packages.lst
echo "htop" >> plugins/brew/packages.lst

# Add to packages-cask.lst
echo "discord" >> plugins/brew/packages-cask.lst
```

### Finding Package Names

Search for available packages:
```bash
# Search for command-line tools
brew search [package_name]

# Search for GUI applications
brew search --cask [app_name]
```

## Dependencies

This plugin uses the dotfiles library system:
- `lib/logger` - Logging functionality
- `lib/utils` - Utility functions
- `lib/brew` - Homebrew-specific functions

## How it works

1. **Library Loading**: Sources required library functions
2. **Homebrew Installation**: Calls `brew_install` to ensure Homebrew is available
3. **Package Installation**: Uses `brew_install_pkgs` to install packages from lists
4. **Cask Installation**: Installs GUI applications using the `cask` parameter

## Troubleshooting

### Common Issues

1. **Homebrew installation fails**:
   - Check internet connection
   - Ensure Xcode Command Line Tools are installed:
     ```bash
     xcode-select --install
     ```

2. **Package installation fails**:
   - Update Homebrew: `brew update`
   - Check if package name is correct: `brew search [package]`

3. **Permission issues**:
   - Ensure user has admin privileges
   - Check Homebrew directory permissions

4. **Cask installation fails**:
   - Some casks require manual approval in System Preferences
   - Check if the application is already installed from another source

### Manual Operations

```bash
# Update Homebrew
brew update

# Upgrade all packages
brew upgrade

# List installed packages
brew list

# List installed casks
brew list --cask

# Remove a package
brew uninstall [package_name]

# Remove a cask
brew uninstall --cask [cask_name]
```

## Notes

- This plugin is designed specifically for macOS
- Some casks may require manual user interaction during installation
- The plugin will skip packages that are already installed
- Installation order matters - this plugin should run early in the bootstrap process
- Other plugins may depend on packages installed by this plugin

## Security Considerations

- Homebrew packages are installed from trusted repositories
- GUI applications (casks) are downloaded from official sources
- Some applications may require granting permissions in System Preferences
- Review package lists before installation in sensitive environments
