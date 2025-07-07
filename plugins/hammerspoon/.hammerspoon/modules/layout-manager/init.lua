-- https://shantanugoel.com/2020/08/21/hammerspoon-multiscreen-window-layout-macos/

local This = {}

-- Layout configurations for different work contexts
local layouts = {
  adevinta = {
    { "iTerm2", nil, "Built-in Retina Display", hs.layout.left50, nil, nil },
    { "Google Chrome", nil, "Built-in Retina Display", hs.layout.right50, nil, nil },
    { "Slack", nil, "Built-in Retina Display", hs.layout.maximized, nil, nil },
  },
  personal = {
    { "Safari", nil, "Built-in Retina Display", hs.layout.maximized, nil, nil },
    { "Messages", nil, "Built-in Retina Display", hs.layout.left30, nil, nil },
    { "Music", nil, "Built-in Retina Display", hs.layout.right70, nil, nil },
  },
  develop = {
    { "Visual Studio Code", nil, "Built-in Retina Display", hs.layout.left70, nil, nil },
    { "iTerm2", nil, "Built-in Retina Display", hs.layout.right30, nil, nil },
    { "Google Chrome", nil, "Built-in Retina Display", hs.layout.maximized, nil, nil },
  }
}

-- Function to launch applications for Adevinta workflow
function launchApps()
  hs.alert.show("Launching Adevinta Layout...")
  hs.layout.apply(layouts.adevinta)
end

-- Function to set triple screen layout for personal use
function setTripleScreen()
  hs.alert.show("Setting Personal Layout...")
  hs.layout.apply(layouts.personal)
end

-- Function to set single screen layout for development
function setSingleScreen()
  hs.alert.show("Setting Development Layout...")
  hs.layout.apply(layouts.develop)
end

local menu = hs.menubar.new()
local function enableMenu()
  menu:setTitle("🖥")
  menu:setTooltip("Layout Manager")
  menu:setMenu({
      { title = "Adevinta", fn = launchApps },
      { title = "Personal", fn = setTripleScreen },
      { title = "Develop", fn = setSingleScreen },
      { title = "-" },
      { title = "Reload Config", fn = function() hs.reload() end },
  })
end

enableMenu()

return This
