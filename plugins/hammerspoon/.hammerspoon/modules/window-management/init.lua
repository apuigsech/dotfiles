local This = {}

-- Load configuration
local config = require('config').windowManager

-- Apply configuration
hs.window.animationDuration = config.animationDuration
hs.grid.setGrid(config.gridSize[1] .. "x" .. config.gridSize[2])
hs.grid.setMargins(config.margins)

-- Behaviour flags (previously declared in config but never honoured)
local UNDO_ENABLED = config.enableUndo ~= false
local MAX_HISTORY = config.maxHistorySize or 10
local MULTI_MONITOR = config.enableMultiMonitor ~= false

-- Screen position definitions
This.screenPositions = {
  left = {
    x = 0, y = 0,
    w = 1, h = 2
  },
  midleft = {
    x = 1, y = 0,
    w = 1, h = 2
  },
  midright = {
    x = 2, y = 0,
    w = 1, h = 2
  },
  right = {
    x = 3, y = 0,
    w = 1, h = 2
  },
  fullleft = {
    x = 0, y = 0,
    w = 2, h = 2
  },
  fullmid = {
    x = 1, y = 0,
    w = 2, h = 2
  },
  fullright = {
    x = 2, y = 0,
    w = 2, h = 2
  },
  fullscreen = {
    x = 0, y = 0,
    w = 4, h = 2
  }
}

-- Window history for undo functionality.
-- Each entry is a STACK (array) of prior states, keyed by window id, so undo
-- can walk back multiple moves up to MAX_HISTORY instead of a single level.
local windowHistory = {}

-- Drop all history for a window id (window closed, or stack drained).
local function forgetWindow(id)
  if id then windowHistory[id] = nil end
end

-- Helper function to save window state
local function saveWindowState(window)
  if not UNDO_ENABLED then return end
  if not window then return end
  local windowId = window:id()
  if not windowId then return end

  local stack = windowHistory[windowId]
  if not stack then
    stack = {}
    windowHistory[windowId] = stack
  end

  table.insert(stack, {
    frame = window:frame(),
    screen = window:screen(),
    timestamp = os.time()
  })

  -- Bound the stack: discard the oldest states beyond MAX_HISTORY.
  while #stack > MAX_HISTORY do
    table.remove(stack, 1)
  end
end

-- Helper function to get focused window with error handling
local function getFocusedWindow()
  local window = hs.window.focusedWindow()
  if not window then
    hs.alert.show("No focused window")
    return nil
  end
  return window
end

-- Move window to specific grid position
function This.moveWindowToPosition(cell, window)
  window = window or getFocusedWindow()
  if not window then return end

  saveWindowState(window)
  local screen = window:screen()
  hs.grid.set(window, cell, screen)
end

-- Undo last window movement (pops one state off the window's history stack)
function This.undoWindowMove()
  local window = getFocusedWindow()
  if not window then return end

  if not UNDO_ENABLED then
    hs.alert.show("Undo is disabled")
    return
  end

  local windowId = window:id()
  local stack = windowId and windowHistory[windowId]

  if stack and #stack > 0 then
    local state = table.remove(stack)  -- pop most recent
    window:setFrame(state.frame)
    hs.alert.show("Window position restored")
    if #stack == 0 then
      forgetWindow(windowId)  -- keep the table from growing unbounded
    end
  else
    hs.alert.show("No window history found")
  end
end

-- Switch between left positions
function This.SwitchLeft()
  local window = getFocusedWindow()
  if not window then return end

  local grid = hs.grid.get(window)
  if This.gridEquals(grid, This.screenPositions.midleft) then
    This.moveWindowToPosition(This.screenPositions.left, window)
  else
    This.moveWindowToPosition(This.screenPositions.midleft, window)
  end
end

-- Switch between right positions
function This.SwitchRight()
  local window = getFocusedWindow()
  if not window then return end

  local grid = hs.grid.get(window)
  if This.gridEquals(grid, This.screenPositions.midright) then
    This.moveWindowToPosition(This.screenPositions.right, window)
  else
    This.moveWindowToPosition(This.screenPositions.midright, window)
  end
end

-- Full position functions
function This.FullMid()
  This.moveWindowToPosition(This.screenPositions.fullmid)
end

function This.FullLeft()
  This.moveWindowToPosition(This.screenPositions.fullleft)
end

function This.FullRight()
  This.moveWindowToPosition(This.screenPositions.fullright)
end

function This.FullScreen()
  This.moveWindowToPosition(This.screenPositions.fullscreen)
end

-- Smart full side positioning
function This.FullSide()
  local window = getFocusedWindow()
  if not window then return end

  local grid = hs.grid.get(window)
  if This.gridEquals(grid, This.screenPositions.midleft) or
     This.gridEquals(grid, This.screenPositions.left) then
    This.moveWindowToPosition(This.screenPositions.fullleft, window)
  elseif This.gridEquals(grid, This.screenPositions.midright) or
         This.gridEquals(grid, This.screenPositions.right) then
    This.moveWindowToPosition(This.screenPositions.fullright, window)
  else
    -- Default to full left if window is in center
    This.moveWindowToPosition(This.screenPositions.fullleft, window)
  end
end

-- Move window to next screen
function This.moveToNextScreen()
  local window = getFocusedWindow()
  if not window then return end

  if not MULTI_MONITOR then
    hs.alert.show("Multi-monitor support disabled")
    return
  end

  saveWindowState(window)
  local screen = window:screen()
  local nextScreen = screen:next()

  if nextScreen ~= screen then
    window:moveToScreen(nextScreen)
    hs.alert.show("Moved to " .. nextScreen:name())
  else
    hs.alert.show("Only one screen available")
  end
end

-- Helper function to compare grid positions
function This.gridEquals(grid1, grid2)
  if not grid1 or not grid2 then return false end
  return grid1.x == grid2.x and grid1.y == grid2.y and
         grid1.w == grid2.w and grid1.h == grid2.h
end

-- Center window on screen
function This.centerWindow()
  local window = getFocusedWindow()
  if not window then return end

  saveWindowState(window)
  local screen = window:screen()
  local frame = screen:frame()
  local windowFrame = window:frame()

  windowFrame.x = frame.x + (frame.w - windowFrame.w) / 2
  windowFrame.y = frame.y + (frame.h - windowFrame.h) / 2

  window:setFrame(windowFrame)
end

-- Resize window by percentage
function This.resizeWindow(widthPercent, heightPercent)
  local window = getFocusedWindow()
  if not window then return end

  saveWindowState(window)
  local screen = window:screen()
  local frame = screen:frame()
  local windowFrame = window:frame()

  windowFrame.w = frame.w * (widthPercent / 100)
  windowFrame.h = frame.h * (heightPercent / 100)

  -- Center the resized window
  windowFrame.x = frame.x + (frame.w - windowFrame.w) / 2
  windowFrame.y = frame.y + (frame.h - windowFrame.h) / 2

  window:setFrame(windowFrame)
end

-- Clean up history when a window is closed, so windowHistory does not grow
-- without bound over a long session. Guarded because hs.window.filter is only
-- available inside the real Hammerspoon runtime.
if hs.window and hs.window.filter then
  This._windowFilter = hs.window.filter.new(nil)
  This._windowFilter:subscribe(hs.window.filter.windowDestroyed, function(win)
    if win then forgetWindow(win:id()) end
  end)
end

-- Introspection helper for tests: number of windows currently tracked.
function This._historyCount()
  local n = 0
  for _ in pairs(windowHistory) do n = n + 1 end
  return n
end

return This
