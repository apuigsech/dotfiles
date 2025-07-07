-- Application Launcher Module
-- Provides quick application launching with fuzzy search

local This = {}

-- Load configuration
local config = require('config').applicationLauncher
local displayConfig = require('config').display

-- Application chooser
local chooser = nil
local applications = {}

-- Initialize application launcher
function This.init()
  chooser = hs.chooser.new(This.launchApplication)
  chooser:placeholderText("Search applications...")
  chooser:searchSubText(config.searchSubText)
  chooser:width(config.width)
  chooser:rows(config.maxResults)

  This.refreshApplications()
end

-- Refresh application list
function This.refreshApplications()
  applications = {}

  -- Get all installed applications
  local installedApps = hs.application.applicationsForBundleID("") or {}

  -- Add system applications
  for _, app in ipairs(installedApps) do
    if app:name() then
      table.insert(applications, {
        text = app:name(),
        subText = app:bundleID() or "",
        bundleID = app:bundleID(),
        path = app:path()
      })
    end
  end

  -- Add frequently used applications manually for better ordering
  local frequentApps = {
    {
      text = "iTerm",
      subText = "Terminal",
      bundleID = "com.googlecode.iterm2"
    },
    {
      text = "Google Chrome",
      subText = "Web Browser",
      bundleID = "com.google.Chrome"
    },
    {
      text = "Visual Studio Code",
      subText = "Code Editor",
      bundleID = "com.microsoft.VSCode"
    },
    {
      text = "Slack",
      subText = "Team Communication",
      bundleID = "com.tinyspeck.slackmacgap"
    },
    {
      text = "Finder",
      subText = "File Manager",
      bundleID = "com.apple.finder"
    },
    {
      text = "Safari",
      subText = "Web Browser",
      bundleID = "com.apple.Safari"
    },
    {
      text = "System Preferences",
      subText = "System Settings",
      bundleID = "com.apple.systempreferences"
    },
    {
      text = "Activity Monitor",
      subText = "System Monitor",
      bundleID = "com.apple.ActivityMonitor"
    }
  }

  -- Merge frequent apps with discovered apps, avoiding duplicates
  local appMap = {}
  for _, app in ipairs(applications) do
    appMap[app.bundleID] = app
  end

  for _, app in ipairs(frequentApps) do
    if not appMap[app.bundleID] then
      table.insert(applications, app)
    end
  end

  -- Sort applications alphabetically
  table.sort(applications, function(a, b)
    return a.text < b.text
  end)

  if chooser then
    chooser:choices(applications)
  end
end

-- Launch selected application
function This.launchApplication(choice)
  if not choice then return end

  local success, result = pcall(function()
    if choice.bundleID then
      hs.application.launchOrFocusByBundleID(choice.bundleID)
    else
      hs.application.launchOrFocus(choice.text)
    end
  end)

  if success then
    if displayConfig.showAlerts then
      hs.alert.show("Launching " .. choice.text, 1)
    end
  else
    hs.alert.show("Failed to launch " .. choice.text)
    print("Application launch failed:", result)
  end
end

-- Show application launcher
function This.show()
  if chooser then
    chooser:show()
  end
end

-- Hide application launcher
function This.hide()
  if chooser then
    chooser:hide()
  end
end

-- Quick launch specific applications
function This.launchTerminal()
  This.quickLaunch(config.applications.terminal)
end

function This.launchBrowser()
  This.quickLaunch(config.applications.browser)
end

function This.launchEditor()
  This.quickLaunch(config.applications.editor)
end

function This.launchChat()
  This.quickLaunch(config.applications.chat)
end

-- Quick launch helper
function This.quickLaunch(appName)
  local success, result = pcall(function()
    hs.application.launchOrFocus(appName)
  end)

  if success then
    if displayConfig.showAlerts then
      hs.alert.show("Launching " .. appName, 1)
    end
  else
    hs.alert.show("Failed to launch " .. appName)
    print("Quick launch failed:", result)
  end
end

-- Get running applications
function This.getRunningApplications()
  local running = {}
  local runningApps = hs.application.runningApplications()

  for _, app in ipairs(runningApps) do
    if app:name() and not app:isHidden() then
      table.insert(running, {
        name = app:name(),
        bundleID = app:bundleID(),
        pid = app:pid(),
        windows = #app:allWindows()
      })
    end
  end

  return running
end

-- Switch between running applications
function This.showAppSwitcher()
  local runningApps = This.getRunningApplications()

  if #runningApps == 0 then
    hs.alert.show("No running applications")
    return
  end

  local choices = {}
  for _, app in ipairs(runningApps) do
    table.insert(choices, {
      text = app.name,
      subText = string.format("PID: %d, Windows: %d", app.pid, app.windows),
      bundleID = app.bundleID
    })
  end

  local appSwitcher = hs.chooser.new(function(choice)
    if choice and choice.bundleID then
      hs.application.launchOrFocusByBundleID(choice.bundleID)
    end
  end)

  appSwitcher:placeholderText("Switch to application...")
  appSwitcher:choices(choices)
  appSwitcher:show()
end

-- Quit application
function This.quitApplication(appName)
  local app = hs.application.find(appName)
  if app then
    app:kill()
    if config.display.showAlerts then
      hs.alert.show("Quit " .. appName)
    end
  else
    hs.alert.show(appName .. " not found")
  end
end

-- Force quit application
function This.forceQuitApplication(appName)
  local app = hs.application.find(appName)
  if app then
    app:kill9()
    if config.display.showAlerts then
      hs.alert.show("Force quit " .. appName)
    end
  else
    hs.alert.show(appName .. " not found")
  end
end

-- Show application menu
function This.showApplicationMenu()
  local runningApps = This.getRunningApplications()
  local menu = {}

  -- Running applications section
  table.insert(menu, {
    title = "Running Applications",
    disabled = true
  })

  for _, app in ipairs(runningApps) do
    table.insert(menu, {
      title = app.name,
      fn = function()
        hs.application.launchOrFocus(app.name)
      end
    })
  end

  -- Separator
  table.insert(menu, { title = "-" })

  -- Quick actions
  table.insert(menu, {
    title = "Launch Application...",
    fn = function()
      This.show()
    end
  })

  table.insert(menu, {
    title = "Switch Application...",
    fn = function()
      This.showAppSwitcher()
    end
  })

  table.insert(menu, {
    title = "Refresh App List",
    fn = function()
      This.refreshApplications()
    end
  })

  return menu
end

-- Get application information
function This.getApplicationInfo(appName)
  local app = hs.application.find(appName)
  if not app then
    return nil
  end

  return {
    name = app:name(),
    bundleID = app:bundleID(),
    path = app:path(),
    pid = app:pid(),
    isRunning = true,
    isHidden = app:isHidden(),
    windows = #app:allWindows(),
    mainWindow = app:mainWindow() and app:mainWindow():title() or nil
  }
end

-- Auto-position applications based on rules
function This.autoPositionApplication(appName)
  local rules = config.autoPositionRules
  local rule = rules[appName]

  if not rule or not rule.autoPosition then
    return
  end

  local app = hs.application.find(appName)
  if not app then
    return
  end

  local window = app:mainWindow()
  if not window then
    return
  end

  -- Apply positioning rule
  local wm = require('modules.window-management')
  local position = rule.defaultPosition

  if position == "left" then
    wm.FullLeft()
  elseif position == "right" then
    wm.FullRight()
  elseif position == "fullscreen" then
    wm.FullScreen()
  elseif position == "center" then
    wm.centerWindow()
  end
end

-- Watch for new applications
function This.initApplicationWatcher()
  local advancedConfig = require('config').advanced
  if not advancedConfig.enableWindowFilters then
    return
  end

  local watcher = hs.application.watcher.new(function(appName, eventType, app)
    if eventType == hs.application.watcher.launched then
      print("Application launched:", appName)
      -- Auto-position after a short delay
      hs.timer.doAfter(1, function()
        This.autoPositionApplication(appName)
      end)
    elseif eventType == hs.application.watcher.terminated then
      print("Application terminated:", appName)
    end
  end)

  watcher:start()
end

return This
