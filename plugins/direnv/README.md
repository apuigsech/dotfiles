# Direnv Plugin

This plugin sets up [direnv](https://direnv.net/), a powerful environment variable manager that automatically loads and unloads environment variables based on the current directory. It's essential for managing project-specific configurations and dependencies.

## What it does

The direnv plugin:

- Enables direnv shell integration for automatic environment loading
- Provides a `direnv_create` utility for quick `.envrc` file creation
- Sets up proper shell hooks for seamless environment switching
- Integrates with the shell plugin for environment management

## Files

- `setup.dotbot` - Dotbot configuration for linking files
- `enable` - Shell integration script for direnv
- `bin/direnv_create` - Utility for creating `.envrc` files
- `.envrc` - Sample environment file (created by user)

## Features

### Automatic Environment Loading
- Loads `.envrc` files when entering directories
- Unloads environment when leaving directories
- Supports nested environments with inheritance
- Provides security through allowlist mechanism

### Shell Integration
- Hooks into shell prompt for automatic execution
- Custom `direnv` function with enhanced functionality
- Integration with zsh and other shells

### Project Management
- Per-project environment variables
- Path modifications for project binaries
- Virtual environment activation
- Configuration isolation

## Dependencies

This plugin requires:
- `direnv` - Installed via the brew plugin
- Shell plugin for environment loading

## Installation

The plugin is automatically installed when running the bootstrap script:

```bash
./bootstap
```

Or install just the direnv plugin:

```bash
cd plugins/direnv
../../dotbot/bin/dotbot -c setup.dotbot
```

## Configuration Locations

Files are linked to:
- `~/.shell/direnv` - Shell integration script
- `~/bin/direnv_create` - Environment creation utility

## Usage

### Basic Usage

1. **Navigate to a project directory**:
   ```bash
   cd /path/to/your/project
   ```

2. **Create an `.envrc` file**:
   ```bash
   direnv_create
   # or manually create .envrc
   echo 'export PROJECT_NAME="myproject"' > .envrc
   ```

3. **Allow the environment**:
   ```bash
   direnv allow
   ```

4. **Environment loads automatically**:
   The environment variables are now active in this directory and subdirectories.

### Using `direnv_create` Utility

The plugin provides a convenient utility for creating `.envrc` files:

```bash
# Create a new .envrc file with interactive prompts
direnv create

# This is equivalent to using the direnv_create binary
direnv_create
```

### Common `.envrc` Patterns

#### Basic Environment Variables
```bash
# .envrc
export PROJECT_NAME="myproject"
export DEBUG=true
export API_URL="http://localhost:3000"
```

#### Path Management
```bash
# .envrc
export PATH="$PWD/bin:$PATH"
export PATH="$PWD/node_modules/.bin:$PATH"
```

#### Virtual Environment Activation
```bash
# .envrc
# Python virtual environment
source_env venv/bin/activate

# Node.js version management
use node 16
```

#### Loading from Files
```bash
# .envrc
# Load from .env file
dotenv

# Load from custom file
dotenv .env.local
```

#### Conditional Loading
```bash
# .envrc
if [[ -f .env.local ]]; then
    dotenv .env.local
fi

# Different configs for different environments
if [[ "$USER" == "production" ]]; then
    export NODE_ENV=production
else
    export NODE_ENV=development
fi
```

## Advanced Features

### Layout Functions

Direnv supports layout functions for common patterns:

```bash
# .envrc
# Python virtual environment
layout python3

# Node.js project
layout node

# Go project
layout go
```

### Environment Inheritance

Child directories inherit parent environments:

```bash
# /project/.envrc
export PROJECT_ROOT="$PWD"
export DATABASE_URL="postgresql://localhost/mydb"

# /project/frontend/.envrc
export NODE_ENV=development
export API_URL="http://localhost:3000"
# DATABASE_URL is still available here
```

### Security Model

Direnv requires explicit approval for security:

```bash
# Allow a specific .envrc
direnv allow

# Allow all .envrc files in directory tree
direnv allow .

# Deny/revoke permission
direnv deny

# Check status
direnv status
```

## Integration with Development Tools

### Docker Development
```bash
# .envrc
export COMPOSE_PROJECT_NAME="myproject"
export DOCKER_BUILDKIT=1
```

### AWS Development
```bash
# .envrc
export AWS_PROFILE="development"
export AWS_REGION="us-west-2"
```

### Database Development
```bash
# .envrc
export DATABASE_URL="postgresql://localhost:5432/myproject_dev"
export REDIS_URL="redis://localhost:6379"
```

## Troubleshooting

### Common Issues

1. **Environment not loading**:
   ```bash
   # Check if direnv is hooked
   direnv status

   # Reload shell configuration
   source ~/.zshrc
   ```

2. **Permission denied**:
   ```bash
   # Allow the .envrc file
   direnv allow

   # Check current status
   direnv status
   ```

3. **Variables not persisting**:
   - Ensure `.envrc` is in the correct directory
   - Check for syntax errors in `.envrc`
   - Verify direnv hook is loaded in shell

4. **Slow shell performance**:
   ```bash
   # Check what direnv is doing
   direnv status

   # Optimize .envrc files
   # Avoid expensive operations in .envrc
   ```

### Debug Commands

```bash
# Show current direnv status
direnv status

# Show loaded environment
direnv export json

# Reload current environment
direnv reload

# Show direnv version
direnv version

# Test .envrc without loading
direnv exec . env
```

## Best Practices

### File Organization
- Keep `.envrc` files simple and fast
- Use `.env` files for actual values, `.envrc` for loading logic
- Document environment variables in README files

### Security
- Never commit sensitive data in `.envrc` files
- Use `.env.example` files to document required variables
- Regularly audit allowed directories: `direnv status`

### Performance
- Avoid expensive operations in `.envrc`
- Cache computed values when possible
- Use conditional loading for optional dependencies

## Integration

This plugin integrates with:
- **Shell plugin**: For environment variable management
- **Zsh plugin**: For prompt integration
- **Development workflows**: Project-specific configurations

## Notes

- Direnv requires explicit permission for each `.envrc` file
- Environment changes are temporary and scoped to directory trees
- The plugin enhances the default `direnv` command with additional functionality
- Works with any shell that supports direnv hooks
