-- System Monitor Module
-- Displays system information in the menu bar

local This = {}

-- Load configuration
local config = require('config').systemMonitor
local advancedConfig = require('config').advanced
local updateInterval = config.updateInterval

-- Menu bar item
local menuBar = nil
local updateTimer = nil

-- System information cache
local systemInfo = {
  battery = 0,
  wifi = "Unknown",
  cpu = 0,
  memory = 0,
  lastUpdate = 0
}

-- Initialize menu bar
function This.init()
  if not config.showInMenuBar then
    return
  end

  menuBar = hs.menubar.new()
  if menuBar then
    menuBar:setTooltip("System Monitor")
    This.updateSystemInfo()
    This.startUpdateTimer()
  end
end

-- Update system information
function This.updateSystemInfo()
  local success, result = pcall(function()
    -- Battery information
    systemInfo.battery = hs.battery.percentage() or 0

    -- WiFi information
    systemInfo.wifi = hs.wifi.currentNetwork() or "Not connected"

    -- CPU usage (if available)
    local cpuUsage = hs.host.cpuUsage()
    if cpuUsage and cpuUsage.overall then
      systemInfo.cpu = math.floor(cpuUsage.overall.active or 0)
    end

        -- Memory usage
    local vmStats = hs.host.vmStat()
    if vmStats and vmStats.memSize and vmStats.memFree then
      local totalMemory = vmStats.memSize
      local usedMemory = (vmStats.memSize - vmStats.memFree)
      if totalMemory > 0 then
        systemInfo.memory = math.floor((usedMemory / totalMemory) * 100)
      end
    else
      -- Fallback method for memory calculation
      local hostInfo = hs.host.vmStat()
      if hostInfo and hostInfo.memSize then
        -- This is a rough estimate, not exact usage
        local totalMemory = hostInfo.memSize
        local freeMemory = (hostInfo.memFree or 0) + (hostInfo.memInactive or 0)
        if totalMemory > 0 then
          systemInfo.memory = math.floor(((totalMemory - freeMemory) / totalMemory) * 100)
        else
          systemInfo.memory = 0
        end
      else
        systemInfo.memory = 0  -- Set to 0 if we can't get accurate data
      end
    end

    systemInfo.lastUpdate = os.time()
    This.updateMenuBar()
  end)

  if not success then
    print("System monitor update failed:", result)
  end
end

-- Update menu bar display
function This.updateMenuBar()
  if not menuBar then return end

  local batteryIcon = This.getBatteryIcon(systemInfo.battery)
  local wifiIcon = systemInfo.wifi ~= "Not connected" and "📶" or "📵"

  local title = string.format("%s%d%% %s",
    batteryIcon,
    systemInfo.battery,
    wifiIcon
  )

  menuBar:setTitle(title)
  menuBar:setMenu(This.createMenu())
end

-- Get battery icon based on charge level
function This.getBatteryIcon(percentage)
  if percentage >= 90 then
    return "🔋"
  elseif percentage >= 60 then
    return "🔋"
  elseif percentage >= 30 then
    return "🪫"
  else
    return "🪫"
  end
end

-- Create menu items
function This.createMenu()
  local menu = {}

  -- System information section
  table.insert(menu, {
    title = string.format("Battery: %d%%", systemInfo.battery),
    disabled = true
  })

  table.insert(menu, {
    title = string.format("WiFi: %s", systemInfo.wifi),
    disabled = true
  })

  if systemInfo.cpu > 0 then
    table.insert(menu, {
      title = string.format("CPU: %d%%", systemInfo.cpu),
      disabled = true
    })
  end

  if systemInfo.memory > 0 then
    table.insert(menu, {
      title = string.format("Memory: %d%%", systemInfo.memory),
      disabled = true
    })
  end

  -- Separator
  table.insert(menu, { title = "-" })

  -- Quick actions
  table.insert(menu, {
    title = "System Preferences",
    fn = function()
      hs.application.launchOrFocus("System Preferences")
    end
  })

  table.insert(menu, {
    title = "Activity Monitor",
    fn = function()
      hs.application.launchOrFocus("Activity Monitor")
    end
  })

  table.insert(menu, {
    title = "Network Utility",
    fn = function()
      hs.application.launchOrFocus("Network Utility")
    end
  })

  -- Separator
  table.insert(menu, { title = "-" })

  -- System actions
  table.insert(menu, {
    title = "Lock Screen",
    fn = function()
      hs.caffeinate.lockScreen()
    end
  })

  table.insert(menu, {
    title = "Sleep",
    fn = function()
      hs.caffeinate.systemSleep()
    end
  })

  -- Separator
  table.insert(menu, { title = "-" })

  -- Control options
  table.insert(menu, {
    title = "Refresh",
    fn = function()
      This.updateSystemInfo()
    end
  })

  table.insert(menu, {
    title = "Disable Monitor",
    fn = function()
      This.stop()
    end
  })

  return menu
end

-- Start update timer
function This.startUpdateTimer()
  if updateTimer then
    updateTimer:stop()
  end

  updateTimer = hs.timer.doEvery(updateInterval, function()
    This.updateSystemInfo()
  end)
end

-- Stop system monitor
function This.stop()
  if updateTimer then
    updateTimer:stop()
    updateTimer = nil
  end

  if menuBar then
    menuBar:delete()
    menuBar = nil
  end
end

-- Get current system information
function This.getSystemInfo()
  return systemInfo
end

-- Show detailed system information
function This.showDetailedInfo()
  local screen = hs.screen.mainScreen()
  local mode = screen:currentMode()
  local uptime = hs.host.uptime()
  local uptimeHours = math.floor(uptime / 3600)
  local uptimeMinutes = math.floor((uptime % 3600) / 60)

  local info = string.format([[
System Information:

Battery: %d%%
WiFi: %s
CPU Usage: %d%%
Memory Usage: %d%%
Screen: %dx%d
Uptime: %dh %dm

Last Updated: %s
]],
    systemInfo.battery,
    systemInfo.wifi,
    systemInfo.cpu,
    systemInfo.memory,
    mode.w, mode.h,
    uptimeHours, uptimeMinutes,
    os.date("%H:%M:%S", systemInfo.lastUpdate)
  )

  hs.alert.show(info, 5)
end

-- Handle system events
function This.handleSystemEvent(eventType)
  if eventType == hs.caffeinate.watcher.systemWillSleep then
    print("System going to sleep")
  elseif eventType == hs.caffeinate.watcher.systemDidWake then
    print("System woke up")
    -- Update system info after wake
    hs.timer.doAfter(2, function()
      This.updateSystemInfo()
    end)
  end
end

-- Initialize system event watchers
function This.initSystemWatchers()
  if config.enableSystemWatchers then
    local systemWatcher = hs.caffeinate.watcher.new(This.handleSystemEvent)
    systemWatcher:start()
  end
end

return This
