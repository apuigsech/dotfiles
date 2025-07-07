-- Hammerspoon Configuration Settings
-- Customize these settings to match your preferences

local config = {}

-- =============================================================================
-- FEATURE TOGGLES - Enable/Disable Components
-- =============================================================================

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
  caffeine = true,                -- Prevent system sleep
  musicControl = true,            -- Music playback control
  menuBarClock = false,           -- Custom menu bar clock
  weatherWidget = false,          -- Weather information
  todoManager = false,            -- Simple todo list
}

-- =============================================================================
-- WINDOW MANAGEMENT SETTINGS
-- =============================================================================

config.windowManager = {
  enabled = config.features.windowManager,

  -- Animation settings
  animationDuration = 0,          -- Animation speed (0 = instant, 0.5 = slow)

  -- Grid configuration
  gridSize = {4, 2},              -- Grid dimensions [width, height]
  margins = {0, 0},               -- Grid margins [x, y]

  -- History settings
  enableUndo = true,              -- Enable window position undo
  maxHistorySize = 10,            -- Maximum undo history per window

  -- Multi-monitor settings
  enableMultiMonitor = true,      -- Enable multi-monitor support
  autoDetectScreens = true,       -- Auto-detect screen configurations

  -- Window positioning
  enableSmartPositioning = true,  -- Smart positioning based on screen type
  enableWindowRules = true,       -- Application-specific window rules
}

-- =============================================================================
-- APPLICATION LAUNCHER SETTINGS
-- =============================================================================

config.applicationLauncher = {
  enabled = config.features.applicationLauncher,

  -- Chooser settings
  searchSubText = true,           -- Search in application descriptions
  maxResults = 8,                 -- Maximum results to show
  width = 20,                     -- Chooser width

  -- Quick launch applications
  applications = {
    terminal = "iTerm",           -- Terminal application
    browser = "Google Chrome",    -- Web browser
    editor = "Visual Studio Code", -- Code editor
    chat = "Slack",               -- Chat application
    finder = "Finder",            -- File manager
    notes = "Notes",              -- Notes application
  },

  -- Auto-positioning rules
  autoPositionRules = {
    ["iTerm2"] = {
      defaultPosition = "left",
      autoPosition = true
    },
    ["Google Chrome"] = {
      defaultPosition = "right",
      autoPosition = false
    },
    ["Visual Studio Code"] = {
      defaultPosition = "fullscreen",
      autoPosition = true
    }
  }
}

-- =============================================================================
-- SYSTEM MONITOR SETTINGS
-- =============================================================================

config.systemMonitor = {
  enabled = config.features.systemMonitor,

  -- Update settings
  updateInterval = 30,            -- Update interval in seconds
  showInMenuBar = true,           -- Show in menu bar

  -- Display settings
  showBattery = true,             -- Show battery percentage
  showWiFi = true,                -- Show WiFi status
  showCPU = false,                -- Show CPU usage (can be resource intensive)
  showMemory = false,             -- Show memory usage
  showUptime = false,             -- Show system uptime

  -- Menu bar format
  compactMode = true,             -- Compact display in menu bar
  showIcons = true,               -- Show status icons

  -- System events
  enableSystemWatchers = true,    -- Monitor system events (sleep/wake)
  enableBatteryWatcher = true,    -- Monitor battery events
  enableWiFiWatcher = true,       -- Monitor WiFi events
}

-- =============================================================================
-- LAYOUT MANAGER SETTINGS
-- =============================================================================

config.layoutManager = {
  enabled = config.features.layoutManager,

  -- Predefined layouts
  layouts = {
    development = {
      name = "Development",
      enabled = true,
      apps = {
        {"Visual Studio Code", nil, "Built-in Retina Display", "left70", nil, nil},
        {"iTerm2", nil, "Built-in Retina Display", "right30", nil, nil},
        {"Google Chrome", nil, "Built-in Retina Display", "maximized", nil, nil}
      }
    },

    productivity = {
      name = "Productivity",
      enabled = true,
      apps = {
        {"Slack", nil, "Built-in Retina Display", "left30", nil, nil},
        {"Google Chrome", nil, "Built-in Retina Display", "right70", nil, nil},
        {"Notes", nil, "Built-in Retina Display", "maximized", nil, nil}
      }
    },

    meeting = {
      name = "Meeting",
      enabled = true,
      apps = {
        {"Zoom", nil, "Built-in Retina Display", "maximized", nil, nil},
        {"Slack", nil, "Built-in Retina Display", "left50", nil, nil},
        {"Notes", nil, "Built-in Retina Display", "right50", nil, nil}
      }
    },

    design = {
      name = "Design",
      enabled = false,
      apps = {
        {"Figma", nil, "Built-in Retina Display", "maximized", nil, nil},
        {"Finder", nil, "Built-in Retina Display", "left30", nil, nil},
      }
    }
  }
}

-- =============================================================================
-- CLIPBOARD MANAGER SETTINGS
-- =============================================================================

config.clipboardManager = {
  enabled = config.features.clipboardManager,

  -- History settings
  maxHistorySize = 20,            -- Maximum clipboard items to remember

  -- Display settings
  showTimestamps = true,          -- Show timestamps in history
  previewLength = 60,             -- Maximum preview text length

  -- Persistence settings
  saveHistory = false,            -- Save history between sessions
  historyFile = "clipboard_history.json", -- History file name

  -- Filtering settings
  ignoreEmptyItems = true,        -- Ignore empty clipboard items
  ignoreDuplicates = true,        -- Ignore duplicate items
  ignorePasswords = true,         -- Ignore password-like content
}

-- =============================================================================
-- CAFFEINE SETTINGS
-- =============================================================================

config.caffeine = {
  enabled = config.features.caffeine,

  -- Display settings
  showInMenuBar = true,           -- Show caffeine status in menu bar
  compactMode = true,             -- Compact menu bar display

  -- System monitoring
  enableSystemWatcher = true,     -- Monitor system sleep events

  -- Default durations (in seconds)
  defaultDurations = {
    short = 15 * 60,              -- 15 minutes
    medium = 60 * 60,             -- 1 hour
    long = 2 * 60 * 60,           -- 2 hours
  },

  -- Auto-disable settings
  autoDisableOnBattery = false,   -- Auto-disable when on battery
  batteryThreshold = 20,          -- Battery percentage threshold
}

-- =============================================================================
-- MUSIC CONTROL SETTINGS
-- =============================================================================

config.musicControl = {
  enabled = config.features.musicControl,

  -- Display settings
  showInMenuBar = true,           -- Show music controls in menu bar
  showTrackInfo = false,          -- Show current track in menu bar (can be long)
  compactMode = true,             -- Compact menu bar display

  -- Update settings
  autoUpdate = true,              -- Auto-update track info and status
  updateInterval = 30,            -- Update interval in seconds

  -- Supported applications
  supportedApps = {
    "Spotify",                    -- Spotify music streaming
    "Music",                      -- Apple Music
    "iTunes",                     -- iTunes (legacy)
  },

  -- Control settings
  enableVolumeControl = true,     -- Enable volume control
  enableTrackInfo = true,         -- Show detailed track information
  enableNotifications = true,     -- Show notifications for track changes
}

-- =============================================================================
-- HOTKEY SETTINGS
-- =============================================================================

config.hotkeys = {
  enabled = config.features.hotkeys,

  -- Modifier key combinations
  windowModifiers = {"cmd", "alt"},       -- Window management
  appModifiers = {"cmd", "alt"},          -- Application control
  systemModifiers = {"cmd", "alt"},       -- System functions
  resizeModifiers = {"cmd", "alt", "ctrl"}, -- Window resizing

  -- Key mappings
  keys = {
    -- Window management
    left = "left",
    right = "right",
    up = "up",
    down = "down",
    fullscreen = "f",
    center = "c",
    nextScreen = "n",
    undo = "z",

    -- Applications
    launcher = "a",
    switcher = "tab",
    terminal = "t",
    browser = "b",
    editor = "v",
    chat = "s",

    -- System
    reload = "r",
    info = "i",
    help = "h",

    -- Future hotkeys
    clipboard = "p",      -- Clipboard manager
    textExpander = "e",   -- Text expander
    screenshot = "x",     -- Screenshot tools
        caffeine = "k",       -- Caffeine toggle (K for keep awake)
    music = "m",          -- Music control info
    }
}

-- =============================================================================
-- DISPLAY SETTINGS
-- =============================================================================

config.display = {
  -- Alert settings
  showAlerts = true,              -- Show status alerts
  alertDuration = 2,              -- Alert display duration in seconds

  -- Menu bar settings
  enableMenuBar = config.features.systemMonitor or config.features.layoutManager,

  -- Auto-reload settings
  enableAutoReload = config.features.autoReload,

  -- Debug settings
  enableDebugMode = false,        -- Enable debug output
  verboseLogging = false,         -- Verbose logging
}

-- =============================================================================
-- ADVANCED SETTINGS
-- =============================================================================

config.advanced = {
  -- Performance settings
  debounceTime = 0.1,             -- Debounce time for rapid key presses
  maxConcurrentAnimations = 3,    -- Maximum concurrent window animations

  -- Monitoring settings
  enableWindowFilters = config.features.windowManager,
  enableSystemWatchers = config.features.systemMonitor,
  enableNetworkMonitoring = config.features.networkMonitor,
  enableBatteryMonitoring = config.features.systemMonitor,

  -- Resource limits
  maxHistoryEntries = 100,        -- Maximum history entries across all features
  maxLogFileSize = 10485760,      -- Maximum log file size (10MB)

  -- Security settings
  allowScriptExecution = false,   -- Allow external script execution
  enableRemoteControl = false,    -- Enable remote control features
}

-- =============================================================================
-- LOGGING SETTINGS
-- =============================================================================

config.logging = {
  level = "info",                 -- Log level: debug, info, warning, error
  enableConsoleOutput = true,     -- Enable console logging
  enableFileOutput = false,       -- Enable file logging
  logFile = "hammerspoon.log",    -- Log file name

  -- Module-specific logging
  moduleLogging = {
    windowManager = "info",
    applicationLauncher = "info",
    systemMonitor = "warning",
    layoutManager = "info",
  }
}

-- =============================================================================
-- HELPER FUNCTIONS
-- =============================================================================

-- Check if a feature is enabled
function config.isFeatureEnabled(featureName)
  return config.features[featureName] == true
end

-- Get feature-specific configuration
function config.getFeatureConfig(featureName)
  return config[featureName] or {}
end

-- Validate configuration
function config.validate()
  local errors = {}

  -- Check for required features
  if config.features.hotkeys and not config.hotkeys.enabled then
    table.insert(errors, "Hotkeys feature is enabled but hotkeys.enabled is false")
  end

  -- Check for conflicting settings
  if config.features.systemMonitor and not config.systemMonitor.enabled then
    table.insert(errors, "System monitor feature is enabled but systemMonitor.enabled is false")
  end

  return #errors == 0, errors
end

return config
