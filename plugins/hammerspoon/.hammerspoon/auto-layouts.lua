' https://shantanugoel.com/2020/08/21/hammerspoon-multiscreen-window-layout-macos/

local This = {}

local menu = hs.menubar.new()
local function enableMenu()
  menu:setTitle("🖥")
  menu:setTooltip("No Layout")
  menu:setMenu({
      { title = "Adevinta", fn = launchApps },
      { title = "Personal", fn = setTripleScreen },
      { title = "Develop", fn = setSingleScreen },
  })
end

enableMenu()


return This