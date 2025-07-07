-- Caffeine Module
-- Prevents system sleep with visual indicator and manual control

local This = {}

-- Load configuration and utilities
local config = require('config').caffeine or {}
local Utils = require('modules.utils')
local logger = Utils.createLogger("caffeine")

-- Module state
local menuBar = nil
local isActive = false
local caffeineWatcher = nil

-- Initialize caffeine module
function This.init()
  if not Utils.initModule("caffeine", function()
    This.setupMenuBar()
    This.setupWatcher()
    logger.i("Caffeine module ready")
  end) then
    return
  end
end

-- Setup menu bar indicator
function This.setupMenuBar()
  if not config.showInMenuBar then
    return
  end

  menuBar = hs.menubar.new()
  if menuBar then
    This.updateMenuBar()
    menuBar:setTooltip("Caffeine - Prevent Sleep")
    menuBar:setMenu(This.createMenu())
    menuBar:setClickCallback(This.toggleCaffeine)
  end
end

-- Update menu bar display
function This.updateMenuBar()
  if not menuBar then return end

  local icon = isActive and "☕" or "😴"
  local title = config.compactMode and icon or (icon .. " " .. (isActive and "Active" or "Inactive"))

  menuBar:setTitle(title)
end

-- Create menu items
function This.createMenu()
  local menu = {}

  -- Status section
  table.insert(menu, {
    title = "Status: " .. (isActive and "Active (Preventing Sleep)" or "Inactive"),
    disabled = true
  })

  table.insert(menu, { title = "-" })

  -- Toggle action
  table.insert(menu, {
    title = isActive and "Disable Caffeine" or "Enable Caffeine",
    fn = This.toggleCaffeine
  })

  -- Duration presets
  if not isActive then
    table.insert(menu, { title = "-" })
    table.insert(menu, {
      title = "Enable for 15 minutes",
      fn = function() This.enableForDuration(15 * 60) end
    })
    table.insert(menu, {
      title = "Enable for 1 hour",
      fn = function() This.enableForDuration(60 * 60) end
    })
    table.insert(menu, {
      title = "Enable for 2 hours",
      fn = function() This.enableForDuration(2 * 60 * 60) end
    })
  end

  table.insert(menu, { title = "-" })

  -- System actions
  table.insert(menu, {
    title = "Sleep Now",
    fn = function()
      This.disable()
      hs.caffeinate.systemSleep()
    end
  })

  table.insert(menu, {
    title = "Display Sleep",
    fn = function()
      hs.caffeinate.displaySleep()
    end
  })

  return menu
end

-- Toggle caffeine state
function This.toggleCaffeine()
  if isActive then
    This.disable()
  else
    This.enable()
  end
end

-- Enable caffeine
function This.enable()
  if isActive then return end

  hs.caffeinate.set("displayIdle", true)
  hs.caffeinate.set("systemIdle", true)
  hs.caffeinate.set("system", true)

  isActive = true
  This.updateMenuBar()

  Utils.notifySuccess("Caffeine enabled - Sleep prevented")
  logger.i("Caffeine enabled")
end

-- Disable caffeine
function This.disable()
  if not isActive then return end

  hs.caffeinate.set("displayIdle", false)
  hs.caffeinate.set("systemIdle", false)
  hs.caffeinate.set("system", false)

  isActive = false
  This.updateMenuBar()

  Utils.notifyInfo("Caffeine disabled - Sleep allowed")
  logger.i("Caffeine disabled")
end

-- Enable for specific duration
function This.enableForDuration(seconds)
  This.enable()

  local minutes = math.floor(seconds / 60)
  Utils.notifyInfo("Caffeine enabled for " .. minutes .. " minutes")

  hs.timer.doAfter(seconds, function()
    This.disable()
    Utils.notifyInfo("Caffeine timer expired - Sleep allowed")
  end)
end

-- Setup system event watcher
function This.setupWatcher()
  if not config.enableSystemWatcher then
    return
  end

  caffeineWatcher = hs.caffeinate.watcher.new(function(eventType)
    if eventType == hs.caffeinate.watcher.systemWillSleep then
      if isActive then
        logger.w("System attempting to sleep while caffeine is active")
      end
    elseif eventType == hs.caffeinate.watcher.systemDidWake then
      logger.i("System woke up")
      This.updateMenuBar()
    end
  end)

  caffeineWatcher:start()
end

-- Get current state
function This.isActive()
  return isActive
end

-- Get status information
function This.getStatus()
  return {
    active = isActive,
    displayIdle = hs.caffeinate.get("displayIdle"),
    systemIdle = hs.caffeinate.get("systemIdle"),
    system = hs.caffeinate.get("system")
  }
end

-- Cleanup function
function This.stop()
  if isActive then
    This.disable()
  end

  if menuBar then
    menuBar:delete()
    menuBar = nil
  end

  if caffeineWatcher then
    caffeineWatcher:stop()
    caffeineWatcher = nil
  end

  logger.i("Caffeine module stopped")
end

return This
