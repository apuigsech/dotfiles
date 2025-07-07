-- Hammerspoon Configuration
-- Main initialization file with modular feature system

-- Load configuration first
local config = require('config')
local log = hs.logger.new("hammerspoon", config.logging.level)

-- Validate configuration
local isValid, errors = config.validate()
if not isValid then
  for _, error in ipairs(errors) do
    log.e("Configuration error:", error)
  end
  hs.alert.show("Configuration errors found. Check console.")
end

-- =============================================================================
-- MODULE LOADING
-- =============================================================================

local modules = {}

-- Load window management module
if config.isFeatureEnabled("windowManager") then
  log.i("Loading window management module...")
  modules.wm = require('modules.window-management')
end

-- Load application launcher module
if config.isFeatureEnabled("applicationLauncher") then
  log.i("Loading application launcher module...")
  modules.appLauncher = require('modules.application-launcher')
  modules.appLauncher.init()

  if config.windowManager.enableWindowRules then
    modules.appLauncher.initApplicationWatcher()
  end
end

-- Load system monitor module
if config.isFeatureEnabled("systemMonitor") then
  log.i("Loading system monitor module...")
  modules.systemMonitor = require('modules.system-monitor')
  modules.systemMonitor.init()

  if config.systemMonitor.enableSystemWatchers then
    modules.systemMonitor.initSystemWatchers()
  end
end

-- Load layout manager module
if config.isFeatureEnabled("layoutManager") then
  log.i("Loading layout manager module...")
  modules.autoLayouts = require('modules.layout-manager')
end

-- Load clipboard manager module (if enabled)
if config.isFeatureEnabled("clipboardManager") then
  log.i("Loading clipboard manager module...")
  modules.clipboardManager = require('modules.clipboard-manager')
  modules.clipboardManager.init()
end

-- Load caffeine module (if enabled)
if config.isFeatureEnabled("caffeine") then
  log.i("Loading caffeine module...")
  modules.caffeine = require('modules.caffeine')
  modules.caffeine.init()
end

-- Load music control module (if enabled)
if config.isFeatureEnabled("musicControl") then
  log.i("Loading music control module...")
  modules.musicControl = require('modules.music-control')
  modules.musicControl.init()
end

-- =============================================================================
-- AUTO-RELOAD CONFIGURATION
-- =============================================================================

if config.isFeatureEnabled("autoReload") then
  local function reloadConfig(files)
    local doReload = false
    for _, file in pairs(files) do
      if file:sub(-4) == ".lua" then
        doReload = true
        break
      end
    end
    if doReload then
      log.i("Configuration files changed, reloading...")
      hs.reload()
    end
  end

  local configWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig)
  configWatcher:start()
  log.i("Auto-reload enabled")
end

-- =============================================================================
-- SCREEN MODE DETECTION
-- =============================================================================

-- Dynamic screen mode detection
local function getScreenMode()
  local screen = hs.screen.mainScreen()
  local mode = screen:currentMode()
  local aspectRatio = mode.w / mode.h

  -- Ultra-wide monitors typically have aspect ratio > 2.0
  if aspectRatio > 2.0 then
    return "ultra_wide"
  else
    return "single_monitor"
  end
end

-- =============================================================================
-- WINDOW MANAGEMENT KEY MODES
-- =============================================================================

local KEYMODES = {}

if config.isFeatureEnabled("windowManager") and modules.wm then
  KEYMODES = {
    single_monitor = {
      left = modules.wm.FullLeft,
      right = modules.wm.FullRight,
      down = modules.wm.FullMid,
      up = modules.wm.FullScreen,
      f = modules.wm.FullScreen
    },
    ultra_wide = {
      left = modules.wm.SwitchLeft,
      right = modules.wm.SwitchRight,
      down = modules.wm.FullMid,
      up = modules.wm.FullSide,
      f = modules.wm.FullScreen
    }
  }
end

-- =============================================================================
-- UTILITY FUNCTIONS
-- =============================================================================

-- Safe function execution with error handling
local function safeExecute(func, errorMsg)
  local success, result = pcall(func)
  if not success then
    log.e(errorMsg or "Function execution failed", result)
    if config.display.showAlerts then
      hs.alert.show("Error: " .. (errorMsg or "Operation failed"))
    end
  end
  return success, result
end

-- Key handler with dynamic mode detection
local function executeKeyCommand(key)
  if not config.isFeatureEnabled("windowManager") or not modules.wm then
    return
  end

  safeExecute(function()
    local screenMode = getScreenMode()
    local keyMode = KEYMODES[screenMode]

    if keyMode and keyMode[key] then
      log.d("Executing key command:", key, "in mode:", screenMode)
      keyMode[key]()
    else
      log.w("No key mapping found for:", key, "in mode:", screenMode)
    end
  end, "Key command execution failed")
end

-- =============================================================================
-- HOTKEY BINDINGS
-- =============================================================================

if config.isFeatureEnabled("hotkeys") then
  local hotkeys = config.hotkeys

  -- Window management hotkeys
  if config.isFeatureEnabled("windowManager") and modules.wm then
    hs.hotkey.bind(hotkeys.windowModifiers, hotkeys.keys.left, function() executeKeyCommand("left") end)
    hs.hotkey.bind(hotkeys.windowModifiers, hotkeys.keys.right, function() executeKeyCommand("right") end)
    hs.hotkey.bind(hotkeys.windowModifiers, hotkeys.keys.up, function() executeKeyCommand("up") end)
    hs.hotkey.bind(hotkeys.windowModifiers, hotkeys.keys.down, function() executeKeyCommand("down") end)
    hs.hotkey.bind(hotkeys.windowModifiers, hotkeys.keys.fullscreen, function() executeKeyCommand("f") end)

    -- Additional window management hotkeys
    hs.hotkey.bind(hotkeys.windowModifiers, hotkeys.keys.center, function()
      safeExecute(modules.wm.centerWindow, "Center window failed")
    end)

    hs.hotkey.bind(hotkeys.windowModifiers, hotkeys.keys.nextScreen, function()
      safeExecute(modules.wm.moveToNextScreen, "Move to next screen failed")
    end)

    hs.hotkey.bind(hotkeys.windowModifiers, hotkeys.keys.undo, function()
      safeExecute(modules.wm.undoWindowMove, "Undo window move failed")
    end)

    -- Window resizing hotkeys
    hs.hotkey.bind(hotkeys.resizeModifiers, "1", function()
      safeExecute(function() modules.wm.resizeWindow(50, 50) end, "Resize window failed")
    end)

    hs.hotkey.bind(hotkeys.resizeModifiers, "2", function()
      safeExecute(function() modules.wm.resizeWindow(75, 75) end, "Resize window failed")
    end)

    hs.hotkey.bind(hotkeys.resizeModifiers, "3", function()
      safeExecute(function() modules.wm.resizeWindow(100, 100) end, "Resize window failed")
    end)

    log.i("Window management hotkeys enabled")
  end

  -- Application launcher hotkeys
  if config.isFeatureEnabled("applicationLauncher") and modules.appLauncher then
    hs.hotkey.bind(hotkeys.appModifiers, hotkeys.keys.terminal, function()
      safeExecute(modules.appLauncher.launchTerminal, "Launch terminal failed")
    end)

    hs.hotkey.bind(hotkeys.appModifiers, hotkeys.keys.browser, function()
      safeExecute(modules.appLauncher.launchBrowser, "Launch browser failed")
    end)

    hs.hotkey.bind(hotkeys.appModifiers, hotkeys.keys.editor, function()
      safeExecute(modules.appLauncher.launchEditor, "Launch editor failed")
    end)

    hs.hotkey.bind(hotkeys.appModifiers, hotkeys.keys.chat, function()
      safeExecute(modules.appLauncher.launchChat, "Launch chat failed")
    end)

    -- Application launcher chooser
    hs.hotkey.bind(hotkeys.appModifiers, hotkeys.keys.launcher, function()
      safeExecute(modules.appLauncher.show, "Show app launcher failed")
    end)

    -- Application switcher
    hs.hotkey.bind(hotkeys.appModifiers, hotkeys.keys.switcher, function()
      safeExecute(modules.appLauncher.showAppSwitcher, "Show app switcher failed")
    end)

    log.i("Application launcher hotkeys enabled")
  end

  -- Clipboard manager hotkeys
  if config.isFeatureEnabled("clipboardManager") and modules.clipboardManager then
    hs.hotkey.bind(hotkeys.systemModifiers, hotkeys.keys.clipboard, function()
      safeExecute(modules.clipboardManager.showHistory, "Show clipboard history failed")
    end)

    log.i("Clipboard manager hotkeys enabled")
  end

  -- Caffeine hotkeys
  if config.isFeatureEnabled("caffeine") and modules.caffeine then
    hs.hotkey.bind(hotkeys.systemModifiers, hotkeys.keys.caffeine, function()
      safeExecute(modules.caffeine.toggleCaffeine, "Toggle caffeine failed")
    end)

    log.i("Caffeine hotkeys enabled")
  end

  -- Music control hotkeys
  if config.isFeatureEnabled("musicControl") and modules.musicControl then
    hs.hotkey.bind(hotkeys.systemModifiers, hotkeys.keys.music, function()
      safeExecute(modules.musicControl.showDetailedInfo, "Show music info failed")
    end)

    -- Media keys (if available)
    hs.hotkey.bind({}, "f8", function()
      safeExecute(modules.musicControl.togglePlayPause, "Toggle play/pause failed")
    end)

    hs.hotkey.bind({}, "f9", function()
      safeExecute(modules.musicControl.nextTrack, "Next track failed")
    end)

    hs.hotkey.bind({}, "f7", function()
      safeExecute(modules.musicControl.previousTrack, "Previous track failed")
    end)

    log.i("Music control hotkeys enabled")
  end

  -- System hotkeys
  hs.hotkey.bind(hotkeys.systemModifiers, hotkeys.keys.reload, function()
    hs.alert.show("Reloading Hammerspoon configuration...")
    hs.reload()
  end)

  if config.isFeatureEnabled("systemMonitor") and modules.systemMonitor then
    hs.hotkey.bind(hotkeys.systemModifiers, hotkeys.keys.info, function()
      safeExecute(modules.systemMonitor.showDetailedInfo, "System info failed")
    end)
  end

  -- Help hotkey
  hs.hotkey.bind(hotkeys.systemModifiers, hotkeys.keys.help, function()
    local helpText = "Hammerspoon Hotkeys:\n\n"

    if config.isFeatureEnabled("windowManager") then
      helpText = helpText .. "Window Management:\n"
      helpText = helpText .. "⌘⌥ + Arrow Keys - Position windows\n"
      helpText = helpText .. "⌘⌥ + F - Fullscreen\n"
      helpText = helpText .. "⌘⌥ + C - Center window\n"
      helpText = helpText .. "⌘⌥ + N - Move to next screen\n"
      helpText = helpText .. "⌘⌥ + Z - Undo window move\n\n"
    end

    if config.isFeatureEnabled("applicationLauncher") then
      helpText = helpText .. "Applications:\n"
      helpText = helpText .. "⌘⌥ + A - App launcher\n"
      helpText = helpText .. "⌘⌥ + Tab - App switcher\n"
      helpText = helpText .. "⌘⌥ + T - Terminal\n"
      helpText = helpText .. "⌘⌥ + B - Browser\n"
      helpText = helpText .. "⌘⌥ + V - Editor\n"
      helpText = helpText .. "⌘⌥ + S - Chat\n\n"
    end

    if config.isFeatureEnabled("windowManager") then
      helpText = helpText .. "Window Resizing:\n"
      helpText = helpText .. "⌘⌥⌃ + 1 - 50% size\n"
      helpText = helpText .. "⌘⌥⌃ + 2 - 75% size\n"
      helpText = helpText .. "⌘⌥⌃ + 3 - 100% size\n\n"
    end

        helpText = helpText .. "System:\n"
    helpText = helpText .. "⌘⌥ + R - Reload config\n"

    if config.isFeatureEnabled("systemMonitor") then
      helpText = helpText .. "⌘⌥ + I - System info\n"
    end

    if config.isFeatureEnabled("clipboardManager") then
      helpText = helpText .. "⌘⌥ + P - Clipboard history\n"
    end

    if config.isFeatureEnabled("caffeine") then
      helpText = helpText .. "⌘⌥ + K - Toggle caffeine\n"
    end

    if config.isFeatureEnabled("musicControl") then
      helpText = helpText .. "⌘⌥ + M - Music info\n"
      helpText = helpText .. "F7/F8/F9 - Music controls\n"
    end

    helpText = helpText .. "⌘⌥ + H - Show this help"

    hs.alert.show(helpText, 10)
  end)

  log.i("System hotkeys enabled")
end

-- =============================================================================
-- INITIALIZATION COMPLETE
-- =============================================================================

-- Show enabled features
local enabledFeatures = {}
for feature, enabled in pairs(config.features) do
  if enabled then
    table.insert(enabledFeatures, feature)
  end
end

log.i("Hammerspoon configuration loaded successfully")
log.i("Enabled features:", table.concat(enabledFeatures, ", "))

if config.display.showAlerts then
  hs.alert.show("Hammerspoon loaded! Press ⌘⌥H for help", config.display.alertDuration)
end
