-- Music Control Module
-- Controls music playback across various applications

local This = {}

-- Load configuration and utilities
local config = require('config').musicControl or {}
local Utils = require('modules.utils')
local logger = Utils.createLogger("musicControl")

-- Module state
local menuBar = nil
local currentApp = nil
local currentTrack = nil
local isPlaying = false
local updateTimer = nil

-- Supported music applications
local musicApps = {
  ["Spotify"] = {
    name = "Spotify",
    icon = "♫",
    commands = {
      play = function() hs.spotify.play() end,
      pause = function() hs.spotify.pause() end,
      next = function() hs.spotify.next() end,
      previous = function() hs.spotify.previous() end,
      getCurrentTrack = function() return hs.spotify.getCurrentTrack() end,
      isPlaying = function() return hs.spotify.isPlaying() end,
      getVolume = function() return hs.spotify.getVolume() end,
      setVolume = function(volume) hs.spotify.setVolume(volume) end
    }
  },
  ["Music"] = {
    name = "Music",
    icon = "♪",
    commands = {
      play = function() hs.itunes.play() end,
      pause = function() hs.itunes.pause() end,
      next = function() hs.itunes.next() end,
      previous = function() hs.itunes.previous() end,
      getCurrentTrack = function() return hs.itunes.getCurrentTrack() end,
      isPlaying = function() return hs.itunes.isPlaying() end,
      getVolume = function() return hs.itunes.getVolume() end,
      setVolume = function(volume) hs.itunes.setVolume(volume) end
    }
  }
}

-- Initialize music control module
function This.init()
  if not Utils.initModule("musicControl", function()
    This.detectMusicApp()
    This.setupMenuBar()
    This.setupTimer()
    logger.i("Music control module ready")
  end) then
    return
  end
end

-- Detect active music application
function This.detectMusicApp()
  local previousApp = currentApp and currentApp.name or nil

  for appName, appConfig in pairs(musicApps) do
    local app = hs.application.find(appName)
    if app and app:isRunning() then
      if not currentApp or currentApp.name ~= appName then
        currentApp = appConfig
        logger.i("Detected music app:", appName)
      else
        currentApp = appConfig
      end
      return
    end
  end

  if currentApp then
    logger.i("Music app no longer detected:", previousApp)
    currentApp = nil
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
    menuBar:setTooltip("Music Control")
    menuBar:setMenu(This.createMenu())
    menuBar:setClickCallback(This.togglePlayPause)
  end
end

-- Update menu bar display
function This.updateMenuBar()
  if not menuBar then return end

  local title = "♫"

  if currentApp then
    local success, playing = pcall(currentApp.commands.isPlaying)
    isPlaying = success and playing or false

    if config.showTrackInfo and currentTrack then
      local trackText = Utils.truncateString(currentTrack.artist .. " - " .. currentTrack.name, 30)
      title = (isPlaying and "▶ " or "⏸ ") .. trackText
    else
      title = currentApp.icon .. (isPlaying and " ▶" or " ⏸")
    end
  else
    title = "♫ --"
  end

  menuBar:setTitle(title)
end

-- Create menu items
function This.createMenu()
  local menu = {}

  if not currentApp then
    table.insert(menu, {
      title = "No music app detected",
      disabled = true
    })
    return menu
  end

  -- Current track info
  if currentTrack then
    table.insert(menu, {
      title = "♫ " .. currentTrack.name,
      disabled = true
    })
    table.insert(menu, {
      title = "by " .. currentTrack.artist,
      disabled = true
    })
    if currentTrack.album then
      table.insert(menu, {
        title = "from " .. currentTrack.album,
        disabled = true
      })
    end
    table.insert(menu, { title = "-" })
  end

  -- Playback controls
  table.insert(menu, {
    title = isPlaying and "⏸ Pause" or "▶ Play",
    fn = This.togglePlayPause
  })

  table.insert(menu, {
    title = "⏮ Previous",
    fn = This.previousTrack
  })

  table.insert(menu, {
    title = "⏭ Next",
    fn = This.nextTrack
  })

  table.insert(menu, { title = "-" })

  -- Volume controls
  local volume = This.getVolume()
  if volume then
    table.insert(menu, {
      title = "🔊 Volume: " .. volume .. "%",
      disabled = true
    })

    table.insert(menu, {
      title = "🔇 Mute",
      fn = function() This.setVolume(0) end
    })

    table.insert(menu, {
      title = "🔉 50%",
      fn = function() This.setVolume(50) end
    })

    table.insert(menu, {
      title = "🔊 100%",
      fn = function() This.setVolume(100) end
    })

    table.insert(menu, { title = "-" })
  end

  -- Application controls
  table.insert(menu, {
    title = "Show " .. currentApp.name,
    fn = function()
      local app = hs.application.find(currentApp.name)
      if app then
        app:activate()
      end
    end
  })

  table.insert(menu, {
    title = "Refresh",
    fn = function()
      This.detectMusicApp()
      This.updateTrackInfo()
    end
  })

  return menu
end

-- Toggle play/pause
function This.togglePlayPause()
  if not currentApp then
    This.detectMusicApp()
    if not currentApp then
      Utils.notifyError("No music app detected")
      return
    end
  end

  Utils.safeExecute(function()
    if isPlaying then
      currentApp.commands.pause()
      Utils.notifyInfo("Music paused")
    else
      currentApp.commands.play()
      Utils.notifyInfo("Music playing")
    end
  end, "Toggle play/pause failed", logger)
end

-- Next track
function This.nextTrack()
  if not currentApp then return end

  Utils.safeExecute(function()
    currentApp.commands.next()
    Utils.notifyInfo("Next track")
    -- Update track info after a short delay
    hs.timer.doAfter(1, This.updateTrackInfo)
  end, "Next track failed", logger)
end

-- Previous track
function This.previousTrack()
  if not currentApp then return end

  Utils.safeExecute(function()
    currentApp.commands.previous()
    Utils.notifyInfo("Previous track")
    -- Update track info after a short delay
    hs.timer.doAfter(1, This.updateTrackInfo)
  end, "Previous track failed", logger)
end

-- Get current volume
function This.getVolume()
  if not currentApp then return nil end

  local success, volume = pcall(currentApp.commands.getVolume)
  return success and volume or nil
end

-- Set volume
function This.setVolume(volume)
  if not currentApp then return end

  Utils.safeExecute(function()
    currentApp.commands.setVolume(volume)
    Utils.notifyInfo("Volume set to " .. volume .. "%")
  end, "Set volume failed", logger)
end

-- Update track information
function This.updateTrackInfo()
  if not currentApp then return end

  local success, track = pcall(currentApp.commands.getCurrentTrack)
  if success and track then
    currentTrack = track
    logger.d("Updated track info:", track.name, "by", track.artist)
  else
    currentTrack = nil
    logger.d("No track info available")
  end

  This.updateMenuBar()
end

-- Setup update timer
function This.setupTimer()
  if not config.autoUpdate then return end

  updateTimer = hs.timer.doEvery(config.updateInterval, function()
    This.detectMusicApp()
    if currentApp then
      This.updateTrackInfo()
    end
  end)
end

-- Get current status
function This.getStatus()
  return {
    app = currentApp and currentApp.name or nil,
    track = currentTrack,
    playing = isPlaying,
    volume = This.getVolume()
  }
end

-- Show detailed music info
function This.showDetailedInfo()
  if not currentApp then
    Utils.notifyError("No music app detected")
    return
  end

  local status = This.getStatus()
  local info = "Music Status:\n\n"

  info = info .. "App: " .. (status.app or "Unknown") .. "\n"
  info = info .. "Status: " .. (status.playing and "Playing" or "Paused") .. "\n"

  if status.track then
    info = info .. "Track: " .. status.track.name .. "\n"
    info = info .. "Artist: " .. status.track.artist .. "\n"
    if status.track.album then
      info = info .. "Album: " .. status.track.album .. "\n"
    end
  end

  if status.volume then
    info = info .. "Volume: " .. status.volume .. "%\n"
  end

  hs.alert.show(info, 5)
end

-- Cleanup function
function This.stop()
  if updateTimer then
    updateTimer:stop()
    updateTimer = nil
  end

  if menuBar then
    menuBar:delete()
    menuBar = nil
  end

  logger.i("Music control module stopped")
end

return This
