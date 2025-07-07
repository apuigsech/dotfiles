-- Utilities Module
-- Shared helper functions for all Hammerspoon modules

local Utils = {}

-- =============================================================================
-- LOGGING UTILITIES
-- =============================================================================

-- Create a logger for a module
function Utils.createLogger(moduleName, level)
  local config = require('config').logging
  local logLevel = level or config.moduleLogging[moduleName] or config.level
  return hs.logger.new(moduleName, logLevel)
end

-- Safe function execution with error handling
function Utils.safeExecute(func, errorMsg, logger)
  local success, result = pcall(func)
  if not success then
    local msg = errorMsg or "Function execution failed"
    if logger then
      logger.e(msg, result)
    else
      print("Error:", msg, result)
    end

    local displayConfig = require('config').display
    if displayConfig.showAlerts then
      hs.alert.show("Error: " .. msg)
    end
  end
  return success, result
end

-- =============================================================================
-- STRING UTILITIES
-- =============================================================================

-- Truncate string to specified length
function Utils.truncateString(str, maxLength, suffix)
  if not str then return "" end
  suffix = suffix or "..."
  if #str <= maxLength then
    return str
  end
  return str:sub(1, maxLength - #suffix) .. suffix
end

-- Clean string for display (remove newlines, extra spaces)
function Utils.cleanString(str)
  if not str then return "" end
  return str:gsub("\n", " "):gsub("\r", " "):gsub("%s+", " "):match("^%s*(.-)%s*$")
end

-- Check if string contains any of the patterns
function Utils.containsAny(str, patterns)
  if not str or not patterns then return false end
  str = str:lower()
  for _, pattern in ipairs(patterns) do
    if str:find(pattern:lower(), 1, true) then
      return true
    end
  end
  return false
end

-- =============================================================================
-- TABLE UTILITIES
-- =============================================================================

-- Deep copy a table
function Utils.deepCopy(orig)
  local copy
  if type(orig) == 'table' then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
      copy[Utils.deepCopy(orig_key)] = Utils.deepCopy(orig_value)
    end
    setmetatable(copy, Utils.deepCopy(getmetatable(orig)))
  else
    copy = orig
  end
  return copy
end

-- Merge two tables
function Utils.mergeTables(t1, t2)
  local result = Utils.deepCopy(t1)
  for k, v in pairs(t2) do
    if type(v) == "table" and type(result[k]) == "table" then
      result[k] = Utils.mergeTables(result[k], v)
    else
      result[k] = v
    end
  end
  return result
end

-- Check if table contains value
function Utils.tableContains(table, value)
  for _, v in pairs(table) do
    if v == value then
      return true
    end
  end
  return false
end

-- =============================================================================
-- TIME UTILITIES
-- =============================================================================

-- Format timestamp for display
function Utils.formatTime(timestamp, format)
  format = format or "%H:%M:%S"
  return os.date(format, timestamp)
end

-- Get human readable time difference
function Utils.timeAgo(timestamp)
  local now = os.time()
  local diff = now - timestamp

  if diff < 60 then
    return "just now"
  elseif diff < 3600 then
    local minutes = math.floor(diff / 60)
    return minutes .. " min ago"
  elseif diff < 86400 then
    local hours = math.floor(diff / 3600)
    return hours .. " hour" .. (hours > 1 and "s" or "") .. " ago"
  else
    local days = math.floor(diff / 86400)
    return days .. " day" .. (days > 1 and "s" or "") .. " ago"
  end
end

-- =============================================================================
-- FILE UTILITIES
-- =============================================================================

-- Check if file exists
function Utils.fileExists(path)
  local file = io.open(path, "r")
  if file then
    file:close()
    return true
  end
  return false
end

-- Read file contents
function Utils.readFile(path)
  local file = io.open(path, "r")
  if not file then return nil end
  local content = file:read("*all")
  file:close()
  return content
end

-- Write file contents
function Utils.writeFile(path, content)
  local file = io.open(path, "w")
  if not file then return false end
  file:write(content)
  file:close()
  return true
end

-- Get config directory path
function Utils.getConfigPath()
  return os.getenv("HOME") .. "/.hammerspoon"
end

-- =============================================================================
-- SYSTEM UTILITIES
-- =============================================================================

-- Get system information
function Utils.getSystemInfo()
  local screen = hs.screen.mainScreen()
  local mode = screen:currentMode()
  local battery = hs.battery.percentage() or 0
  local wifi = hs.wifi.currentNetwork() or "Not connected"
  local uptime = hs.host.uptime()

  return {
    screen = {
      width = mode.w,
      height = mode.h,
      aspectRatio = mode.w / mode.h
    },
    battery = battery,
    wifi = wifi,
    uptime = {
      total = uptime,
      hours = math.floor(uptime / 3600),
      minutes = math.floor((uptime % 3600) / 60)
    }
  }
end

-- Check if running on external display
function Utils.isExternalDisplay()
  local screens = hs.screen.allScreens()
  return #screens > 1
end

-- Get screen type based on aspect ratio
function Utils.getScreenType()
  local screen = hs.screen.mainScreen()
  local mode = screen:currentMode()
  local aspectRatio = mode.w / mode.h

  if aspectRatio > 2.0 then
    return "ultrawide"
  elseif aspectRatio > 1.7 then
    return "widescreen"
  else
    return "standard"
  end
end

-- =============================================================================
-- NOTIFICATION UTILITIES
-- =============================================================================

-- Show notification with proper configuration
function Utils.notify(title, message, duration)
  local displayConfig = require('config').display
  if not displayConfig.showAlerts then return end

  duration = duration or displayConfig.alertDuration
  hs.alert.show(message, duration)
end

-- Show success notification
function Utils.notifySuccess(message, duration)
  Utils.notify("Success", "✅ " .. message, duration)
end

-- Show error notification
function Utils.notifyError(message, duration)
  Utils.notify("Error", "❌ " .. message, duration)
end

-- Show info notification
function Utils.notifyInfo(message, duration)
  Utils.notify("Info", "ℹ️ " .. message, duration)
end

-- =============================================================================
-- VALIDATION UTILITIES
-- =============================================================================

-- Validate configuration section
function Utils.validateConfig(config, required, optional)
  local errors = {}

  -- Check required fields
  for _, field in ipairs(required or {}) do
    if config[field] == nil then
      table.insert(errors, "Missing required field: " .. field)
    end
  end

  -- Validate optional fields if present
  for field, validator in pairs(optional or {}) do
    if config[field] ~= nil then
      local isValid, error = validator(config[field])
      if not isValid then
        table.insert(errors, "Invalid field " .. field .. ": " .. error)
      end
    end
  end

  return #errors == 0, errors
end

-- Common validators
Utils.validators = {
  isNumber = function(value)
    return type(value) == "number", "must be a number"
  end,
  isString = function(value)
    return type(value) == "string", "must be a string"
  end,
  isBoolean = function(value)
    return type(value) == "boolean", "must be a boolean"
  end,
  isTable = function(value)
    return type(value) == "table", "must be a table"
  end,
  isPositive = function(value)
    return type(value) == "number" and value > 0, "must be a positive number"
  end,
  isInRange = function(min, max)
    return function(value)
      return type(value) == "number" and value >= min and value <= max,
             "must be between " .. min .. " and " .. max
    end
  end
}

-- =============================================================================
-- MODULE UTILITIES
-- =============================================================================

-- Check if module is enabled
function Utils.isModuleEnabled(moduleName)
  local config = require('config')
  return config.isFeatureEnabled(moduleName)
end

-- Get module configuration
function Utils.getModuleConfig(moduleName)
  local config = require('config')
  return config.getFeatureConfig(moduleName)
end

-- Initialize module with standard pattern
function Utils.initModule(moduleName, initFunc)
  if not Utils.isModuleEnabled(moduleName) then
    return false
  end

  local logger = Utils.createLogger(moduleName)
  local success, result = Utils.safeExecute(initFunc, "Failed to initialize " .. moduleName, logger)

  if success then
    logger.i(moduleName .. " module initialized successfully")
  end

  return success
end

return Utils
