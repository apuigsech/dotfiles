# Shell Plugin

This plugin provides essential shell configuration and environment management for cross-shell compatibility. It sets up aliases, environment variables, path management, and shell integration that works across different shell environments.

## What it does

The shell plugin:

- Sets up common shell aliases for enhanced productivity
- Manages environment variables and shell configuration
- Provides path management for development tools
- Creates a foundation for shell-agnostic configurations
- Enables modular shell configuration loading

## Files

- `setup.dotbot` - Dotbot configuration for linking files
- `.aliases/` - Directory containing shell aliases
- `.env` - Environment variables configuration
- `.paths/` - Directory for PATH management
- `.shellrc` - Universal shell configuration loader

## Features

### Universal Shell Support
- Works with bash, zsh, fish, and other shells
- Consistent behavior across different shell environments
- Modular configuration system
- Shell-agnostic alias and function definitions

### Environment Management
- Centralized environment variable configuration
- PATH management for development tools
- Shell integration hooks
- Platform-specific configurations

### Productivity Enhancements
- Common aliases for frequently used commands
- Enhanced command shortcuts
- Directory navigation improvements
- Development workflow optimizations

## Configuration Locations

Files are linked to:
- `~/.aliases` - Shell aliases
- `~/.env` - Environment variables
- `~/.paths` - PATH configurations
- `~/.shellrc` - Universal shell configuration
- `~/.shell/` - Shell configuration directory

## Installation

The plugin is automatically installed when running the bootstrap script:

```bash
./bootstap
```

Or install just the shell plugin:

```bash
cd plugins/shell
../../dotbot/bin/dotbot -c setup.dotbot
```

## Configuration Files

### Shell Aliases (`.aliases/`)

The aliases directory contains modular alias definitions:

```bash
# Common navigation aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# Enhanced ls commands
alias l='ls -lah'
alias la='ls -lAh'
alias ll='ls -lh'
alias ls='ls --color=auto'

# Git aliases
alias g='git'
alias ga='git add'
alias gc='git commit'
alias gd='git diff'
alias gs='git status'
alias gp='git push'
alias gl='git pull'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
```

### Environment Variables (`.env`)

Central location for environment variable definitions:

```bash
# Editor preferences
export EDITOR='code'
export VISUAL='code'

# Development tools
export NODE_ENV='development'
export PYTHONPATH="$HOME/.local/lib/python3.9/site-packages:$PYTHONPATH"

# Locale settings
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# History settings
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
```

### Path Management (`.paths/`)

Modular PATH configuration:

```bash
# Development tools
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Programming languages
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.gem/bin:$PATH"
export PATH="/usr/local/go/bin:$PATH"

# Platform-specific paths
if [[ "$OSTYPE" == "darwin"* ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
    export PATH="/usr/local/bin:$PATH"
fi
```

### Universal Shell Configuration (`.shellrc`)

Main configuration loader:

```bash
# Load shell configurations
[ -f ~/.env ] && source ~/.env
[ -f ~/.aliases ] && source ~/.aliases
[ -f ~/.paths ] && source ~/.paths

# Load shell-specific configurations
for config in ~/.shell/*; do
    [ -f "$config" ] && source "$config"
done

# Load local customizations
[ -f ~/.shellrc.local ] && source ~/.shellrc.local
```

## Usage

### Shell Integration

Add to your shell's configuration file:

#### For Zsh (`~/.zshrc`):
```bash
source ~/.shellrc
```

#### For Bash (`~/.bashrc`):
```bash
source ~/.shellrc
```

#### For Fish (`~/.config/fish/config.fish`):
```fish
if test -f ~/.shellrc
    bass source ~/.shellrc
end
```

### Common Aliases

The plugin provides many useful aliases:

#### Navigation
```bash
# Quick directory navigation
..          # cd ..
...         # cd ../..
~           # cd ~
-           # cd -

# Enhanced listing
l           # ls -lah
la          # ls -lAh
ll          # ls -lh
```

#### Git Shortcuts
```bash
g           # git
ga          # git add
gc          # git commit
gd          # git diff
gs          # git status
gp          # git push
gl          # git pull
```

#### Safety Features
```bash
rm          # rm -i (interactive)
cp          # cp -i (interactive)
mv          # mv -i (interactive)
```

### Customization

#### Adding Custom Aliases

Create files in the `.aliases/` directory:

```bash
# .aliases/custom
alias myalias='echo "Hello World"'
alias work='cd ~/workspace'
alias deploy='./deploy.sh'
```

#### Adding Environment Variables

Add to `.env`:

```bash
# Custom environment variables
export MY_API_KEY='your-api-key'
export PROJECT_ROOT='/path/to/project'
export CUSTOM_PATH='/usr/local/custom/bin'
```

#### Adding Paths

Add to `.paths/`:

```bash
# Custom paths
export PATH="$HOME/custom/bin:$PATH"
export PATH="/opt/custom/bin:$PATH"
```

### Local Customizations

Create `~/.shellrc.local` for machine-specific configurations:

```bash
# Machine-specific settings
export WORK_EMAIL='user@company.com'
export PERSONAL_EMAIL='user@personal.com'

# Local aliases
alias vpn='sudo openvpn --config ~/vpn/config.ovpn'
alias backup='rsync -av ~/Documents/ /backup/location/'
```

## Advanced Features

### Conditional Loading

```bash
# Load configurations based on conditions
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS-specific configurations
    source ~/.shell/macos
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux-specific configurations
    source ~/.shell/linux
fi
```

### Function Definitions

```bash
# Useful functions
mkcd() {
    mkdir -p "$1" && cd "$1"
}

extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}
```

### Shell Detection

```bash
# Detect current shell
if [ -n "$ZSH_VERSION" ]; then
    # Zsh-specific configurations
    setopt AUTO_CD
    setopt HIST_IGNORE_DUPS
elif [ -n "$BASH_VERSION" ]; then
    # Bash-specific configurations
    shopt -s autocd
    shopt -s histappend
fi
```

## Integration

This plugin integrates with:
- **Zsh plugin**: For zsh-specific enhancements
- **Direnv plugin**: For environment variable management
- **Development tools**: For consistent PATH and environment setup

## Troubleshooting

### Common Issues

1. **Aliases not loading**:
   ```bash
   # Check if .shellrc is sourced
   grep -r "shellrc" ~/.zshrc ~/.bashrc

   # Manually source configuration
   source ~/.shellrc
   ```

2. **Environment variables not set**:
   ```bash
   # Check if .env is loaded
   echo $PATH
   env | grep MY_VARIABLE

   # Debug loading
   bash -x ~/.shellrc
   ```

3. **Path not updated**:
   ```bash
   # Check current PATH
   echo $PATH

   # Verify path additions
   which command_name
   ```

4. **Shell-specific issues**:
   - Check shell compatibility
   - Verify syntax for target shell
   - Test with minimal configuration

### Debug Commands

```bash
# Check loaded aliases
alias

# Check environment variables
env

# Check PATH
echo $PATH | tr ':' '\n'

# Test shell configuration
bash -x ~/.shellrc
```

## Best Practices

### Organization
- Keep aliases organized by category
- Use descriptive names for custom configurations
- Document complex aliases and functions
- Regular cleanup of unused configurations

### Performance
- Avoid expensive operations in shell startup
- Use conditional loading for optional features
- Cache results of expensive computations
- Profile shell startup time

### Compatibility
- Test configurations across different shells
- Use portable syntax when possible
- Provide fallbacks for missing commands
- Document shell-specific requirements

## Security Considerations

- Review environment variables for sensitive data
- Avoid hardcoding credentials in shell files
- Use secure methods for sensitive configurations
- Regular audit of shell configurations

## Notes

- Configuration is loaded in order: `.env`, `.aliases`, `.paths`, then `.shell/*`
- Local customizations in `~/.shellrc.local` override default settings
- The plugin provides a foundation for other shell-related plugins
- Works with most POSIX-compatible shells
- Some features may require specific shell versions or tools
