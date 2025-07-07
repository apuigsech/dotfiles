# Configs Plugin

This plugin manages essential configuration files for development tools and utilities. It sets up Git configuration, debugging tools, and download utilities with optimized settings.

## What it does

The configs plugin:

- Links Git configuration files for version control
- Sets up GDB debugger configuration
- Configures wget download utility settings
- Provides a centralized location for tool configurations

## Files

- `setup.dotbot` - Dotbot configuration for linking files
- `.gitconfig` - Global Git configuration
- `.gitconfig.d/` - Directory for modular Git configurations
- `.gitignore` - Global Git ignore patterns
- `.gdbinit` - GDB debugger initialization
- `.wgetrc` - Wget configuration

## Features

### Git Configuration
- Global Git settings and aliases
- Modular configuration support via `.gitconfig.d/`
- Global gitignore patterns for common files
- Optimized settings for development workflow

### Development Tools
- GDB debugger initialization and settings
- Wget configuration for download optimization
- Consistent tool behavior across projects

## Configuration Files

### Git Settings (`.gitconfig`)
The Git configuration includes:
- User information setup
- Useful aliases for common operations
- Diff and merge tool configuration
- Push and pull behavior settings
- Color output configuration

### Global Gitignore (`.gitignore`)
Common patterns to ignore:
- OS-specific files (`.DS_Store`, `Thumbs.db`)
- Editor temporary files
- Compiled binaries and build artifacts
- Log files and temporary directories
- IDE-specific files

### GDB Configuration (`.gdbinit`)
- Enhanced debugging output
- Useful GDB commands and aliases
- Memory and register display settings

### Wget Configuration (`.wgetrc`)
- Download behavior optimization
- User agent and retry settings
- Progress display configuration

## Installation

The plugin is automatically installed when running the bootstrap script:

```bash
./bootstap
```

Or install just the configs plugin:

```bash
cd plugins/configs
../../dotbot/bin/dotbot -c setup.dotbot
```

## Configuration Locations

Files are linked to:
- `~/.gitconfig` - Main Git configuration
- `~/.gitconfig.d/` - Modular Git configurations
- `~/.gitignore` - Global Git ignore patterns
- `~/.gdbinit` - GDB debugger settings
- `~/.wgetrc` - Wget download settings

## Customization

### Git Configuration

The Git configuration is modular. You can:

1. **Edit main config**: Modify `.gitconfig` for global settings
2. **Add modules**: Create files in `.gitconfig.d/` for specific configurations
3. **User-specific settings**: Add personal information:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Adding Git Aliases

Add custom aliases to `.gitconfig`:
```ini
[alias]
    st = status
    co = checkout
    br = branch
    ci = commit
    unstage = reset HEAD --
```

### Global Gitignore

Add patterns to `.gitignore` for files you want to ignore globally:
```
# IDE files
.vscode/
.idea/

# OS files
.DS_Store
Thumbs.db

# Build artifacts
*.o
*.so
*.dylib
```

## Git Configuration Features

### Useful Aliases
- `git st` - Status
- `git co` - Checkout
- `git br` - Branch
- `git ci` - Commit
- `git unstage` - Unstage files

### Enhanced Diff
- Syntax highlighting
- Better word-level diffs
- Submodule diff support

### Improved Logging
- Colorized output
- Graph visualization
- Compact format options

## Troubleshooting

### Common Issues

1. **Git user not set**:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

2. **GDB not loading config**:
   - Check if `.gdbinit` is in home directory
   - Verify GDB version compatibility
   - Check file permissions

3. **Wget not using config**:
   - Verify `.wgetrc` is in home directory
   - Check wget version and supported options

4. **Git aliases not working**:
   - Check `.gitconfig` syntax
   - Verify Git version compatibility
   - Test with `git config --list`

### Validation

Test configurations:
```bash
# Test Git config
git config --list

# Test Git aliases
git st

# Test GDB config
gdb --batch --eval-command="show version"

# Test wget config
wget --help | head -5
```

## Integration

This plugin integrates with:
- **Shell plugin**: For environment variables
- **Zsh plugin**: For Git prompt integration
- **Development workflows**: Consistent tool behavior

## Notes

- Git configuration requires setting user name and email
- Some GDB features may require specific GDB versions
- Wget configuration is optimized for development use
- Global gitignore patterns apply to all repositories
- Configuration files use standard formats and locations

## Security Considerations

- Git configuration may contain sensitive information
- Avoid committing credentials in Git config
- Use Git credential helpers for authentication
- Review global gitignore to prevent accidental commits
