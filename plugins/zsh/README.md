# Zsh Plugin

This plugin provides comprehensive Zsh shell configuration with modern features, productivity enhancements, and a beautiful prompt. It builds on the foundation provided by the shell plugin to deliver a powerful Zsh experience.

## What it does

The zsh plugin:

- Sets up a modern Zsh configuration with enhanced features
- Provides a beautiful and informative prompt
- Enables advanced Zsh features like autocompletion and syntax highlighting
- Configures history management and navigation improvements
- Integrates with Git for enhanced version control workflow

## Files

- `setup.dotbot` - Dotbot configuration for linking files
- `.zshrc` - Main Zsh configuration file
- `.zsh/` - Directory containing Zsh modules and configurations

## Features

### Enhanced Prompt
- Git integration with branch and status information
- Current directory display with intelligent truncation
- Exit status indicators
- Customizable colors and symbols
- Performance optimized for fast rendering

### Advanced Completions
- Intelligent tab completion
- Command-specific completion enhancements
- Case-insensitive matching
- Fuzzy matching capabilities
- Menu-driven completion selection

### History Management
- Extended history with timestamps
- Intelligent history search
- Duplicate removal
- Cross-session history sharing
- History expansion improvements

### Navigation Enhancements
- Auto-cd functionality
- Directory stack management
- Smart directory completion
- Globbing improvements

## Dependencies

This plugin requires:
- Zsh shell (installed via brew plugin)
- Shell plugin for base configuration
- Git for version control integration

## Installation

The plugin is automatically installed when running the bootstrap script:

```bash
./bootstap
```

Or install just the zsh plugin:

```bash
cd plugins/zsh
../../dotbot/bin/dotbot -c setup.dotbot
```

## Configuration Locations

Files are linked to:
- `~/.zshrc` - Main Zsh configuration
- `~/.zsh/` - Zsh modules and configurations

## Configuration Features

### Zsh Options

The configuration enables many useful Zsh options:

```bash
# Navigation
setopt AUTO_CD                # cd by typing directory name
setopt AUTO_PUSHD            # push directories to stack
setopt PUSHD_IGNORE_DUPS     # don't push duplicate directories
setopt PUSHD_SILENT          # don't print directory stack

# History
setopt EXTENDED_HISTORY      # save timestamps
setopt HIST_EXPIRE_DUPS_FIRST # expire duplicates first
setopt HIST_IGNORE_DUPS      # ignore consecutive duplicates
setopt HIST_IGNORE_SPACE     # ignore commands starting with space
setopt HIST_VERIFY           # verify history expansion
setopt SHARE_HISTORY         # share history between sessions

# Completion
setopt COMPLETE_IN_WORD      # complete from both ends
setopt AUTO_MENU             # show completion menu
setopt AUTO_LIST             # list choices on ambiguous completion
setopt AUTO_PARAM_SLASH      # add slash after directory completion

# Globbing
setopt EXTENDED_GLOB         # extended globbing patterns
setopt GLOB_DOTS             # match dotfiles
setopt NUMERIC_GLOB_SORT     # sort numerically
```

### Prompt Configuration

The prompt includes:
- Current working directory (with intelligent truncation)
- Git branch and status information
- Exit status of last command
- User and hostname (when relevant)
- Time stamps (optional)

### Key Bindings

Enhanced key bindings for productivity:

```bash
# Emacs-style bindings
bindkey -e

# History search
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward

# Word movement
bindkey '^[b' backward-word
bindkey '^[f' forward-word

# Line editing
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^K' kill-line
bindkey '^U' kill-whole-line
```

## Advanced Features

### Completion System

The plugin configures Zsh's powerful completion system:

```bash
# Initialize completion system
autoload -Uz compinit && compinit

# Completion matching
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

# Completion menu
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Completion groups
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%B%d%b'
```

### Git Integration

Enhanced Git integration in the prompt:

```bash
# Git branch display
function git_branch() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    [[ -n $branch ]] && echo " ($branch)"
}

# Git status indicators
function git_status() {
    local status
    status=$(git status --porcelain 2>/dev/null)
    [[ -n $status ]] && echo "*"
}
```

### Directory Navigation

Enhanced directory navigation:

```bash
# Directory aliases
alias d='dirs -v'
alias 1='cd -'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'

# Quick directory access
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
```

## Customization

### Custom Prompt

Create custom prompt in `~/.zsh/prompt.zsh`:

```bash
# Custom prompt configuration
PROMPT='%F{blue}%~%f$(git_branch)%F{red}$(git_status)%f %# '
RPROMPT='%F{yellow}[%D{%H:%M:%S}]%f'

# Prompt themes
autoload -Uz promptinit && promptinit
# prompt theme_name
```

### Custom Completions

Add custom completions in `~/.zsh/completions/`:

```bash
# Custom completion for your command
_my_command() {
    local context state line
    _arguments \
        '-h[show help]' \
        '-v[verbose output]' \
        '*:file:_files'
}

compdef _my_command my_command
```

### Custom Functions

Add custom functions in `~/.zsh/functions/`:

```bash
# Useful functions
mkcd() {
    mkdir -p "$1" && cd "$1"
}

extract() {
    if [[ -f $1 ]]; then
        case $1 in
            *.tar.bz2) tar xjf $1 ;;
            *.tar.gz) tar xzf $1 ;;
            *.bz2) bunzip2 $1 ;;
            *.rar) unrar x $1 ;;
            *.gz) gunzip $1 ;;
            *.tar) tar xf $1 ;;
            *.tbz2) tar xjf $1 ;;
            *.tgz) tar xzf $1 ;;
            *.zip) unzip $1 ;;
            *.Z) uncompress $1 ;;
            *.7z) 7z x $1 ;;
            *) echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}
```

### Local Customizations

Create `~/.zshrc.local` for machine-specific configurations:

```bash
# Local Zsh customizations
export LOCAL_SETTING='value'

# Local aliases
alias local_command='command --with-local-options'

# Local functions
local_function() {
    echo "Local function"
}
```

## Performance Optimization

### Startup Time

Monitor and optimize startup time:

```bash
# Profile startup time
time zsh -i -c exit

# Detailed profiling
zmodload zsh/zprof
# Add to beginning of .zshrc
# Add 'zprof' to end of .zshrc
```

### Lazy Loading

Implement lazy loading for expensive operations:

```bash
# Lazy load nvm
nvm() {
    unset -f nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm "$@"
}
```

## Integration

This plugin integrates with:
- **Shell plugin**: For universal shell configurations
- **Direnv plugin**: For environment variable management
- **Git**: For version control integration
- **Development tools**: For enhanced completion and workflow

## Troubleshooting

### Common Issues

1. **Slow startup**:
   ```bash
   # Profile startup
   time zsh -i -c exit

   # Check for expensive operations
   zmodload zsh/zprof
   ```

2. **Completions not working**:
   ```bash
   # Rebuild completion cache
   rm -f ~/.zcompdump*
   compinit

   # Check completion system
   autoload -Uz compinit && compinit -d
   ```

3. **Prompt not displaying correctly**:
   ```bash
   # Check prompt configuration
   echo $PROMPT
   echo $RPROMPT

   # Test prompt functions
   git_branch
   git_status
   ```

4. **History not working**:
   ```bash
   # Check history settings
   echo $HISTFILE
   echo $HISTSIZE

   # Check history options
   setopt | grep HIST
   ```

### Debug Commands

```bash
# Check Zsh version
zsh --version

# List loaded modules
zmodload

# Check options
setopt

# Test key bindings
bindkey

# Check completion system
compinit -d
```

## Best Practices

### Configuration Organization
- Keep configurations modular in `.zsh/` directory
- Use descriptive names for custom functions
- Document complex configurations
- Regular cleanup of unused configurations

### Performance
- Use lazy loading for expensive operations
- Avoid complex operations in prompt functions
- Cache results when possible
- Profile startup time regularly

### Compatibility
- Test configurations with different Zsh versions
- Provide fallbacks for missing features
- Document version requirements
- Use portable syntax when possible

## Security Considerations

- Review custom functions for security implications
- Avoid executing untrusted code in configurations
- Be cautious with history sharing
- Regular audit of Zsh configurations

## Notes

- Requires Zsh 5.0 or later for full functionality
- Some features may require specific Zsh versions
- Configuration loads shell plugin first for base functionality
- Local customizations override default settings
- Performance impact depends on enabled features and prompt complexity

## Advanced Topics

### Custom Widgets

Create custom Zsh widgets:

```bash
# Custom widget function
my-widget() {
    LBUFFER+="custom text"
}

# Register widget
zle -N my-widget

# Bind to key
bindkey '^X^M' my-widget
```

### Completion Caching

Implement completion caching for performance:

```bash
# Cache completions
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
```

### Theme System

Implement a theme system:

```bash
# Theme loader
load_theme() {
    local theme=$1
    [[ -f ~/.zsh/themes/$theme.zsh ]] && source ~/.zsh/themes/$theme.zsh
}

# Load theme
load_theme "mytheme"
```
