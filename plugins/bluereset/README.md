# Bluereset Plugin

This plugin provides a Bluetooth device reset utility that can unpair and re-pair Bluetooth devices based on a configuration file. This is useful for fixing connectivity issues with Bluetooth devices.

## What it does

The bluereset plugin:

- Installs a `bluereset` command-line utility
- Sets up configuration for managing Bluetooth device reset operations
- Provides automated unpair/pair functionality for specified devices

## Files

- `bin/bluereset` - Main Bluetooth reset script
- `setup.dotbot` - Dotbot configuration for linking files
- `.bluereset` - Configuration file template (created by user)

## Features

### Bluetooth Device Management
- Automatically unpair specified Bluetooth devices
- Re-pair and reconnect devices after a delay
- Support for multiple devices via configuration
- JSON-based device discovery using `blueutil`

### Configuration-driven
- Uses `~/.bluereset` configuration file
- Supports custom configuration file paths
- Device specification by name (automatically resolves to MAC address)

## Dependencies

The script requires the following tools to be installed:

- `blueutil` - Bluetooth utility for macOS
- `jq` - JSON processor for parsing device information

These can be installed via Homebrew:
```bash
brew install blueutil jq
```

## Installation

The plugin is automatically installed when running the bootstrap script:

```bash
./bootstap
```

Or install just the bluereset plugin:

```bash
cd plugins/bluereset
../../dotbot/bin/dotbot -c setup.dotbot
```

## Configuration

Create a configuration file at `~/.bluereset` with the following format:

```bash
# Array of device names to reset
DEVICE_NAMES=("AirPods Pro" "Magic Mouse" "Magic Keyboard")
```

## Usage

### Basic Usage
```bash
# Reset devices using default config (~/.bluereset)
bluereset

# Use custom configuration file
bluereset -c /path/to/custom/config

# Show help
bluereset --help
```

### Configuration Examples

Example `~/.bluereset` file:
```bash
# Bluetooth devices to reset
DEVICE_NAMES=(
    "AirPods Pro"
    "Magic Mouse 2"
    "Magic Keyboard"
    "Logitech MX Master 3"
)
```

## How it works

1. **Device Discovery**: Fetches list of paired Bluetooth devices using `blueutil --paired --format json`
2. **Address Resolution**: Matches device names from config to MAC addresses
3. **Unpair**: Unpairs all specified devices
4. **Wait**: Waits 4 seconds for cleanup
5. **Re-pair**: Pairs and connects all devices again

## Troubleshooting

### Common Issues

1. **Permission denied**: Ensure the script has execute permissions
   ```bash
   chmod +x ~/bin/bluereset
   ```

2. **Dependencies missing**: Install required tools
   ```bash
   brew install blueutil jq
   ```

3. **Device not found**: Check that device names in config match exactly with paired device names
   ```bash
   blueutil --paired --format json | jq '.[].name'
   ```

4. **Bluetooth not working**: Ensure Bluetooth is enabled and devices are initially paired

### Debug Tips

- List all paired devices:
  ```bash
  blueutil --paired
  ```

- Check device names:
  ```bash
  blueutil --paired --format json | jq '.[].name'
  ```

- Test individual operations:
  ```bash
  blueutil --unpair [MAC_ADDRESS]
  blueutil --pair [MAC_ADDRESS]
  blueutil --connect [MAC_ADDRESS]
  ```

## Use Cases

- **Daily routine**: Reset problematic Bluetooth devices that frequently disconnect
- **Troubleshooting**: Quick fix for Bluetooth connectivity issues
- **Automation**: Include in scripts or scheduled tasks for maintenance
- **Multiple devices**: Batch reset of several Bluetooth accessories

## Notes

- This plugin is designed for macOS and requires `blueutil`
- The script includes a 4-second delay between unpair and pair operations
- Device names must match exactly as they appear in the Bluetooth system
- Some devices may require manual confirmation during pairing
