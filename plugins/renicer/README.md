# Renicer Plugin

This plugin provides a process priority management utility that automatically adjusts CPU priorities and limits for running processes based on a configuration file. It helps optimize system performance by managing resource-intensive applications.

## What it does

The renicer plugin:

- Installs a `renicer` command-line utility for process priority management
- Sets up configuration for automatic process priority adjustment
- Provides CPU limiting capabilities for specified processes
- Offers both one-time and daemon mode operation

## Files

- `bin/renicer` - Main process priority management script
- `setup.dotbot` - Dotbot configuration for linking files
- `.renicer` - Configuration file template (created by user)

## Features

### Process Priority Management
- Automatically adjust process nice values
- CPU usage limiting with `cpulimit`
- Pattern-based process matching
- Support for multiple processes simultaneously

### Operation Modes
- **One-time mode**: Run once and exit
- **Daemon mode**: Continuous monitoring and adjustment
- Configuration-driven process selection

### Resource Control
- Nice value adjustment (-20 to 19)
- CPU percentage limiting
- Process identification by name patterns

## Dependencies

The script requires the following tools to be installed:

- `renice` - Process priority adjustment (usually built-in)
- `pgrep` - Process search utility (usually built-in)
- `cpulimit` - CPU usage limiting tool

Install cpulimit via Homebrew:
```bash
brew install cpulimit
```

## Installation

The plugin is automatically installed when running the bootstrap script:

```bash
./bootstap
```

Or install just the renicer plugin:

```bash
cd plugins/renicer
../../dotbot/bin/dotbot -c setup.dotbot
```

## Configuration

Create a configuration file at `~/.renicer` with the following format:

```bash
# Format: process_name priority
# process_name can be a pattern that matches process names
# priority is the nice value (-20 to 19, lower = higher priority)

# Example configurations
Chrome 10
firefox 5
Spotify 15
node 0
python -5
```

### Configuration Format

Each line in the configuration file should contain:
- **Process name/pattern**: String to match against process names
- **Priority**: Nice value (-20 to 19)
  - `-20`: Highest priority (use with caution)
  - `0`: Normal priority
  - `19`: Lowest priority

## Usage

### Basic Usage

```bash
# Run once with default config (~/.renicer)
renicer

# Use custom configuration file
renicer -c /path/to/custom/config

# Run in daemon mode (continuous monitoring)
renicer -d

# Daemon mode with custom config
renicer -d -c /path/to/custom/config
```

### Command Line Options

- `-c, --conf [file]`: Specify custom configuration file
- `-d`: Run in daemon mode (continuous monitoring)

### Configuration Examples

#### Basic Priority Management
```bash
# ~/.renicer
# Lower priority for resource-intensive applications
Chrome 10
Firefox 10
Safari 10
Spotify 15
VLC 15

# Higher priority for development tools
Terminal -5
iTerm2 -5
Xcode 0
```

#### Development Environment
```bash
# ~/.renicer
# Background processes
Dropbox 15
Google Drive 15
OneDrive 15

# Development tools - normal to high priority
node 0
python 0
ruby 0
java 5

# Browsers - lower priority when developing
Chrome 10
Firefox 10
```

#### Resource-Constrained System
```bash
# ~/.renicer
# Aggressive priority management
Slack 15
Discord 15
Spotify 19
Steam 19

# Keep system tools responsive
Activity Monitor -10
Finder -5
```

## How it works

1. **Configuration Loading**: Reads process patterns and priorities from config file
2. **Process Discovery**: Uses `pgrep -f` to find processes matching patterns
3. **Priority Adjustment**: Uses `renice` to change process nice values
4. **CPU Limiting**: Uses `cpulimit` to restrict CPU usage to 25% per process
5. **Monitoring**: In daemon mode, repeats every 5 seconds

### Process Matching

The utility uses `pgrep -f` which matches against the full command line, allowing for flexible pattern matching:

```bash
# Matches any process with "node" in the command line
node 5

# Matches Chrome browser specifically
Google Chrome 10

# Matches Python scripts
python 0
```

## Daemon Mode

When run with the `-d` flag, renicer operates as a daemon:

- Continuously monitors and adjusts processes every 5 seconds
- Automatically handles new processes that match patterns
- Runs in the foreground (use with process managers for background operation)

### Running as Background Service

```bash
# Using nohup
nohup renicer -d > /dev/null 2>&1 &

# Using launchd (macOS)
# Create a launchd plist file for automatic startup
```

## Troubleshooting

### Common Issues

1. **Permission denied**:
   ```bash
   # Ensure script has execute permissions
   chmod +x ~/bin/renicer

   # Some processes may require sudo for priority changes
   sudo renicer
   ```

2. **cpulimit not found**:
   ```bash
   # Install cpulimit
   brew install cpulimit
   ```

3. **Processes not found**:
   ```bash
   # Check running processes
   pgrep -f "process_name"

   # List all processes
   ps aux | grep "process_name"
   ```

4. **Configuration not loading**:
   - Check file path and permissions
   - Verify configuration file syntax
   - Ensure no empty lines or invalid characters

### Debug Tips

- **Test process matching**:
  ```bash
  pgrep -f "Chrome"
  ```

- **Check current priorities**:
  ```bash
  ps -eo pid,ni,comm | grep Chrome
  ```

- **Monitor CPU usage**:
  ```bash
  top -o cpu
  ```

- **Test individual operations**:
  ```bash
  # Manual renice
  renice -n 10 -p [PID]

  # Manual cpulimit
  cpulimit -l 25 -p [PID]
  ```

## Use Cases

### Development Environment
- Lower priority for communication apps (Slack, Discord)
- Normal priority for development tools
- Higher priority for system utilities

### Media Production
- High priority for editing software
- Lower priority for background sync services
- Restricted CPU for non-essential applications

### Gaming Setup
- Lowest priority for background applications
- High priority for game processes
- Limited CPU for system monitoring tools

### Server Environment
- High priority for critical services
- Lower priority for maintenance tasks
- CPU limits for resource-intensive processes

## Best Practices

### Configuration Management
- Start with conservative priority adjustments
- Test changes before implementing in daemon mode
- Document your configuration choices
- Regular review and adjustment based on usage patterns

### System Impact
- Avoid extreme priority values (-20, 19) unless necessary
- Monitor system performance after changes
- Be cautious with system processes
- Consider the impact on other users (multi-user systems)

### Security Considerations
- Be careful with sudo usage
- Review processes before applying priorities
- Avoid affecting critical system processes
- Regular auditing of configuration files

## Integration

This plugin integrates with:
- **System monitoring tools**: For performance analysis
- **Process managers**: For daemon operation
- **Development workflows**: For optimized resource allocation

## Notes

- Priority changes may require elevated privileges for some processes
- The script includes a 25% CPU limit for matched processes
- Daemon mode runs every 5 seconds by default
- Process matching is case-sensitive
- Some applications may reset their priority values
- macOS may have restrictions on priority changes for certain processes

## Limitations

- Cannot change priority of processes owned by other users (without sudo)
- Some system processes are protected from priority changes
- CPU limiting may not work with all process types
- Requires manual configuration for each desired process
