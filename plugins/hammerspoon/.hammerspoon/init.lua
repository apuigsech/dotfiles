local log = hs.logger.new("log", "debug")

local wm = require('window-management')

KEYMODE_0 = {
  ["left"] = wm.FullLeft,
  ["right"] = wm.FullRight,
  ["down"] = wm.FullMid,
  ["up"] = wm.FullScreen,
  ["f"] = wm.FullScreen
}

KEYMODE_1 = {
  ["left"] = wm.SwitchLeft,
  ["right"] = wm.SwitchRight,
  ["down"] = wm.FullMid,
  ["up"] = wm.FullSide,
  ["f"] = wm.FullScreen
}

local wm_modes = {}
wm_modes["1440x900"] = KEYMODE_0
wm_modes["1512x982"] = KEYMODE_0
wm_modes["2560x1440"] = KEYMODE_0
wm_modes["5120x1440"] = KEYMODE_1

function K(key)
  s = hs.screen.mainScreen()
  m = s:currentMode()
  mode = m["w"] .. "x" .. m["h"]
  log.d("MODE", mode, key)
  wm_modes[mode][key]()
end

hs.hotkey.bind({"cmd", "alt"}, "left", function() K("left") end)
hs.hotkey.bind({"cmd", "alt"}, "right", function() K("right") end)
hs.hotkey.bind({"cmd", "alt"}, "up", function() K("up") end)
hs.hotkey.bind({"cmd", "alt"}, "down", function() K("down") end)
hs.hotkey.bind({"cmd", "alt"}, "f", function() K("f") end)