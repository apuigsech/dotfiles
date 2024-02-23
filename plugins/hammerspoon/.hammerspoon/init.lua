local log = hs.logger.new("log", "debug")

local wm = require('window-management')

local KEYMODES = {
  [0] = {
    left = wm.FullLeft,
    right = wm.FullRight,
    down = wm.FullMid,
    up = wm.FullScreen,
    f = wm.FullScreen
  },
  [1] = {
    left = wm.SwitchLeft,
    right = wm.SwitchRight,
    down = wm.FullMid,
    up = wm.FullSide,
    f = wm.FullScreen
  }
}

local wm_modes = {
  ["1440x900"] = KEYMODES[0],
  ["1512x982"] = KEYMODES[0],
  ["2560x1440"] = KEYMODES[0],
  ["5120x1440"] = KEYMODES[1]
}

function K(key)
  local s = hs.screen.mainScreen()
  local m = s:currentMode()
  local mode = m.w .. "x" .. m.h
  log.d("MODE", mode, key)
  wm_modes[mode][key]()
end

hs.hotkey.bind({"cmd", "alt"}, "left", function() K("left") end)
hs.hotkey.bind({"cmd", "alt"}, "right", function() K("right") end)
hs.hotkey.bind({"cmd", "alt"}, "up", function() K("up") end)
hs.hotkey.bind({"cmd", "alt"}, "down", function() K("down") end)
hs.hotkey.bind({"cmd", "alt"}, "f", function() K("f") end)