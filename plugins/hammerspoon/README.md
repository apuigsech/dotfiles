# Hammerspoon Plugin

This plugin sets up [Hammerspoon](https://www.hammerspoon.org/), a powerful macOS automation tool that allows you to control your Mac using Lua scripts. It provides window management, application control, and system automation capabilities.

## What it does

The hammerspoon plugin:

- Links Hammerspoon configuration files to the home directory
- Provides a foundation for macOS automation scripts
- Enables custom window management and application control
- Sets up hotkeys and system integration

## Files

- `setup.dotbot` - Dotbot configuration for linking files
- `.hammerspoon/` - Directory containing Hammerspoon configuration
- `.hammerspoon/init.lua` - Main Hammerspoon configuration file
- `.hammerspoon/config.lua` - User-customizable configuration settings
- `.hammerspoon/modules/` - Modular feature directory
  - `window-management/` - Window positioning and management
  - `application-launcher/` - Application launcher with fuzzy search
  - `system-monitor/` - System monitoring and menu bar display
  - `layout-manager/` - Predefined workspace layouts
  - `clipboard-manager/` - Clipboard history management

## Features

### Enhanced Window Management
- Dynamic screen resolution detection
- Smart window positioning with 4x2 grid system
- Window position history and undo functionality
- Smooth window animations
- Multi-monitor support with easy screen switching
- Application-specific window positioning rules

### Advanced Application Control
- Fuzzy search application launcher (⌘⌥A)
- Quick application switcher (⌘⌥Tab)
- Configurable application hotkeys
- Auto-positioning for new applications
- Application lifecycle monitoring

### System Monitoring
- Real-time system information in menu bar
- Battery, WiFi, CPU, and memory monitoring
- System event handling (sleep/wake)
- Quick access to system utilities
- Detailed system information display

### Workspace Management
- Predefined layout presets (Development, Productivity, Meeting)
- Layout switching via menu bar
- Context-aware window arrangements
- Auto-reload configuration on file changes

### Sleep Management
- Caffeine functionality to prevent system sleep
- Timer-based sleep prevention (15 min, 1 hour, 2 hours)
- Menu bar integration with visual indicators
- System event monitoring

### Music Control
- Support for Spotify and Apple Music
- Menu bar playback controls
- Track information display
- Volume control integration
- Media key support

### Customization
- User-configurable settings file
- Customizable hotkeys and modifiers
- Configurable application preferences
- Flexible layout definitions
- Comprehensive logging system
- Modular feature system with easy enable/disable

## Dependencies

This plugin requires:
- Hammerspoon application (installed via brew plugin)
- macOS with accessibility permissions

## Installation

The plugin is automatically installed when running the bootstrap script:

```bash
./bootstap
```

Or install just the hammerspoon plugin:

```bash
cd plugins/hammerspoon
../../dotbot/bin/dotbot -c setup.dotbot
```

## Configuration Location

Files are linked to:
- `~/.hammerspoon/` - Hammerspoon configuration directory

## Default Hotkeys

### Window Management
- `⌘⌥ + Arrow Keys` - Position windows (left, right, up, down)
- `⌘⌥ + F` - Fullscreen current window
- `⌘⌥ + C` - Center window on screen
- `⌘⌥ + N` - Move window to next screen
- `⌘⌥ + Z` - Undo last window movement

### Applications
- `⌘⌥ + A` - Show application launcher with fuzzy search
- `⌘⌥ + Tab` - Switch between running applications
- `⌘⌥ + T` - Launch/focus Terminal (iTerm)
- `⌘⌥ + B` - Launch/focus Browser (Chrome)
- `⌘⌥ + V` - Launch/focus Editor (VS Code)
- `⌘⌥ + S` - Launch/focus Chat (Slack)

### Window Resizing
- `⌘⌥⌃ + 1` - Resize window to 50% of screen
- `⌘⌥⌃ + 2` - Resize window to 75% of screen
- `⌘⌥⌃ + 3` - Resize window to 100% of screen

### System
- `⌘⌥ + R` - Reload Hammerspoon configuration
- `⌘⌥ + I` - Show detailed system information
- `⌘⌥ + H` - Show help with all hotkeys
- `⌘⌥ + K` - Toggle caffeine (prevent system sleep)
- `⌘⌥ + M` - Show music control information

### Music Control
- `F7` - Previous track
- `F8` - Play/pause
- `F9` - Next track

*Note: All hotkeys can be customized in `~/.hammerspoon/config.lua`*

## Setup

### 1. Install Hammerspoon Application

Hammerspoon is installed via the brew plugin as a cask application.

### 2. Grant Accessibility Permissions

1. Open **System Preferences** → **Security & Privacy** → **Privacy**
2. Select **Accessibility** from the left sidebar
3. Click the lock icon and enter your password
4. Add Hammerspoon to the list and check the box

### 3. Launch Hammerspoon

- Launch Hammerspoon from Applications
- It will appear in the menu bar
- The configuration will be automatically loaded

## Modular Feature System

The Hammerspoon configuration uses a modular feature system that allows you to enable/disable components independently. This makes it easy to customize your setup and add new features in the future.

### Module Organization

All modules are organized in the `~/.hammerspoon/modules/` directory:

```
modules/
├── window-management/     # Window positioning and management
├── application-launcher/  # Application launcher and switcher
├── system-monitor/       # System monitoring and menu bar display
├── layout-manager/       # Predefined workspace layouts
├── clipboard-manager/    # Clipboard history management
├── caffeine/             # Prevent system sleep
├── music-control/        # Music playback control
└── utils/               # Shared utility functions
```

### Available Modules

#### Core Modules (Enabled by Default)
- **window-management** - Advanced window positioning, grid management, and multi-monitor support
- **application-launcher** - Fuzzy search app launcher with quick launch shortcuts
- **system-monitor** - Real-time system information in menu bar (battery, WiFi, CPU, memory)
- **layout-manager** - Predefined workspace layouts for different work modes

#### Additional Modules (Enabled by Default)
- **caffeine** - Prevent system sleep with menu bar control and timer functions
- **music-control** - Control Spotify and Apple Music with menu bar integration

#### Optional Modules (Disabled by Default)
- **clipboard-manager** - Clipboard history management (example implementation)

#### Utility Modules
- **utils** - Shared utility functions for logging, validation, notifications, and more

### Feature Toggles

Edit `~/.hammerspoon/config.lua` to enable/disable features:

```lua
config.features = {
  windowManager = true,           -- Window positioning and management
  applicationLauncher = true,     -- App launcher and switcher
  systemMonitor = true,           -- System info in menu bar
  layoutManager = true,           -- Predefined workspace layouts
  hotkeys = true,                 -- Global hotkey system
  autoReload = true,              -- Auto-reload on config changes

  -- Future features (disabled by default)
  clipboardManager = false,       -- Clipboard history management
  textExpander = false,           -- Text expansion snippets
  screenCapture = false,          -- Enhanced screenshot tools
  networkMonitor = false,         -- Network activity monitoring
  volumeControl = false,          -- Advanced volume controls
  brightnessControl = false,      -- Screen brightness controls
  caffeine = false,               -- Prevent system sleep
  menuBarClock = false,           -- Custom menu bar clock
  weatherWidget = false,          -- Weather information
  todoManager = false,            -- Simple todo list
}
```

### Adding New Modules

To add a new module:

1. **Create module directory**: `mkdir ~/.hammerspoon/modules/new-feature`
2. **Create init.lua**: `touch ~/.hammerspoon/modules/new-feature/init.lua`
3. **Follow module template**:
   ```lua
   local This = {}

   -- Load configuration and utilities
   local config = require('config').newFeature or {}
   local Utils = require('modules.utils')
   local logger = Utils.createLogger("newFeature")

   -- Initialize module
   function This.init()
     if not Utils.initModule("newFeature", function()
       -- Module initialization code
       logger.i("New feature module ready")
     end) then
       return
     end
   end

   return This
   ```
4. **Update main config**: Add feature toggle and configuration section to `config.lua`
5. **Update init.lua**: Add conditional loading logic
6. **Add hotkeys**: If needed, add hotkeys in the main init.lua

### Module Best Practices

1. **Conditional Loading**: Always check if the module is enabled using `Utils.initModule()`
2. **Error Handling**: Use `Utils.safeExecute()` for proper error handling and logging
3. **Resource Cleanup**: Provide cleanup functions for watchers/timers in a `stop()` function
4. **Configuration**: Use the centralized config system via `Utils.getModuleConfig()`
5. **Logging**: Use module-specific loggers via `Utils.createLogger()`
6. **Dependencies**: Keep modules self-contained; use utils for shared functionality

## Customization

The configuration system includes comprehensive customization options:

### Window Management Settings
```lua
config.window = {
  animationDuration = 0.2,        -- Animation speed
  gridSize = {4, 2},              -- Grid dimensions
  enableUndo = true,              -- Enable position undo
  maxHistorySize = 10             -- Undo history size
}
```

### Application Preferences
```lua
config.applications = {
  terminal = "iTerm",             -- Your preferred terminal
  browser = "Google Chrome",      -- Your preferred browser
  editor = "Visual Studio Code",  -- Your preferred editor
  chat = "Slack",                -- Your preferred chat app
}
```

### Custom Hotkeys
```lua
config.hotkeys = {
  windowModifiers = {"cmd", "alt"},
  keys = {
    terminal = "t",
    browser = "b",
    editor = "v",
    -- Customize any key mapping
  }
}
```

### Layout Presets
```lua
config.layouts = {
  development = {
    name = "Development",
    apps = {
      {"Visual Studio Code", nil, "Built-in Retina Display", "left70", nil, nil},
      {"iTerm2", nil, "Built-in Retina Display", "right30", nil, nil},
    }
  }
}
```

## Basic Configuration Examples

### Window Management Example

```lua
-- ~/.hammerspoon/init.lua

-- Window management hotkeys
hs.hotkey.bind({"cmd", "alt"}, "Left", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "alt"}, "Right", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + (max.w / 2)
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)
```

### Application Launcher Example

```lua
-- Application launcher hotkeys
hs.hotkey.bind({"cmd", "alt"}, "T", function()
  hs.application.launchOrFocus("iTerm")
end)

hs.hotkey.bind({"cmd", "alt"}, "C", function()
  hs.application.launchOrFocus("Google Chrome")
end)

hs.hotkey.bind({"cmd", "alt"}, "V", function()
  hs.application.launchOrFocus("Visual Studio Code")
end)
```

### System Information Example

```lua
-- Show system information
hs.hotkey.bind({"cmd", "alt"}, "I", function()
  local battery = hs.battery.percentage()
  local wifi = hs.wifi.currentNetwork()
  local message = string.format("Battery: %d%%\nWiFi: %s", battery, wifi or "Not connected")
  hs.alert.show(message)
end)
```

## Common Use Cases

### Window Tiling

```lua
-- Quarter window positioning
local function moveWindow(x, y, w, h)
  return function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x + (max.w * x)
    f.y = max.y + (max.h * y)
    f.w = max.w * w
    f.h = max.h * h
    win:setFrame(f)
  end
end

-- Bind quarter-screen positions
hs.hotkey.bind({"cmd", "ctrl"}, "1", moveWindow(0, 0, 0.5, 0.5))     -- Top-left
hs.hotkey.bind({"cmd", "ctrl"}, "2", moveWindow(0.5, 0, 0.5, 0.5))   -- Top-right
hs.hotkey.bind({"cmd", "ctrl"}, "3", moveWindow(0, 0.5, 0.5, 0.5))   -- Bottom-left
hs.hotkey.bind({"cmd", "ctrl"}, "4", moveWindow(0.5, 0.5, 0.5, 0.5)) -- Bottom-right
```

### Auto-reload Configuration

```lua
-- Auto-reload configuration when files change
function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")
```

### Menu Bar Application

```lua
-- Create menu bar item
local menubar = hs.menubar.new()

function updateMenuBar()
    local battery = hs.battery.percentage()
    local wifi = hs.wifi.currentNetwork()
    menubar:setTitle(string.format("🔋%d%% 📶%s", battery, wifi and "✓" or "✗"))
end

-- Update every 30 seconds
hs.timer.doEvery(30, updateMenuBar)
updateMenuBar()
```

## Advanced Features

### Multi-Monitor Support

```lua
-- Move window to next screen
hs.hotkey.bind({"cmd", "alt"}, "N", function()
  local win = hs.window.focusedWindow()
  local screen = win:screen()
  local nextScreen = screen:next()
  win:moveToScreen(nextScreen)
end)
```

### Application-Specific Rules

```lua
-- Application window filters
local windowFilter = hs.window.filter

-- Automatically tile certain applications
windowFilter.new('iTerm2')
  :subscribe(hs.window.filter.windowCreated, function(window)
    -- Auto-position new iTerm windows
    local f = window:frame()
    local screen = window:screen()
    local max = screen:frame()

    f.x = max.x
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h
    window:setFrame(f)
  end)
```

### System Event Handling

```lua
-- Handle system events
function caffeinateCallback(eventType)
    if (eventType == hs.caffeinate.watcher.systemWillSleep) then
        hs.alert.show("System going to sleep")
    elseif (eventType == hs.caffeinate.watcher.systemDidWake) then
        hs.alert.show("System woke up")
    end
end

caffeinateWatcher = hs.caffeinate.watcher.new(caffeinateCallback)
caffeinateWatcher:start()
```

## Troubleshooting

### Common Issues

1. **Configuration not loading**:
   - Check Hammerspoon is running in menu bar
   - Verify file permissions on `~/.hammerspoon/`
   - Check for Lua syntax errors in configuration

2. **Hotkeys not working**:
   - Ensure accessibility permissions are granted
   - Check for conflicting system shortcuts
   - Verify hotkey syntax in configuration

3. **Window management not working**:
   - Grant accessibility permissions
   - Check if target applications support window manipulation
   - Test with simple applications first

4. **Performance issues**:
   - Avoid complex operations in frequently called functions
   - Use timers instead of continuous polling
   - Profile using Hammerspoon console

### Debug Commands

```lua
-- Enable console logging
hs.logger.defaultLogLevel = "debug"

-- Print to console
print("Debug message")
hs.alert.show("Alert message")

-- Inspect objects
hs.inspect(hs.window.focusedWindow())
```

### Console Access

- Open Hammerspoon console: Click menu bar icon → Console
- Reload configuration: `hs.reload()`
- Test code snippets interactively

## Best Practices

### Configuration Organization

```lua
-- Split configuration into modules
require("window-management")
require("application-launcher")
require("system-automation")
```

### Error Handling

```lua
-- Wrap functions in pcall for error handling
local function safeFunction()
    local success, result = pcall(function()
        -- Your code here
    end)

    if not success then
        hs.alert.show("Error: " .. result)
    end
end
```

### Performance

- Use window filters instead of polling
- Cache expensive operations
- Avoid blocking operations in hotkey handlers

## Integration

This plugin integrates with:
- **macOS System Preferences**: For accessibility permissions
- **Applications**: For window and application control
- **System events**: For automation triggers

## Notes

- Requires macOS and Hammerspoon application
- Accessibility permissions are required for full functionality
- Configuration is written in Lua
- Changes to configuration require reloading Hammerspoon
- Some features may require additional macOS permissions

## Security Considerations

- Hammerspoon has extensive system access
- Review configuration files for security implications
- Be cautious with system automation scripts
- Regularly update Hammerspoon for security patches
