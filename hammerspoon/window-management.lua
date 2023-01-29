local This = {}

hs.window.animationDuration = 0
hs.grid.setGrid("4x2")
hs.grid.setMargins({0, 0})

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

function This.moveWindowToPosition(cell, window)
  if window == nil then
    window = hs.window.focusedWindow()
  end
  if window then
    local screen = window:screen()
    hs.grid.set(window, cell, screen)
  end
end

function This.slideWindow(window)

end

function This.SwitchLeft(cell, window)
  window = hs.window.focusedWindow()
  grid = hs.grid.get(window)
  if (grid == This.screenPositions.midleft) then
    This.moveWindowToPosition(This.screenPositions.left, window)
  else
    This.moveWindowToPosition(This.screenPositions.midleft, window)
  end
end

function This.SwitchRight(cell, window)
  window = hs.window.focusedWindow()
  grid = hs.grid.get(window)
  if (grid == This.screenPositions.midright) then
    This.moveWindowToPosition(This.screenPositions.right, window)
  else
    This.moveWindowToPosition(This.screenPositions.midright, window)
  end
end

function This.FullMid(cell, window)
	This.moveWindowToPosition(This.screenPositions.fullmid)
end

function This.FullLeft(cell, window)
	This.moveWindowToPosition(This.screenPositions.fullleft)
end

function This.FullRight(cell, window)
	This.moveWindowToPosition(This.screenPositions.fullright)
end

function This.FullScreen(cell, window)
	This.moveWindowToPosition(This.screenPositions.fullscreen)
end

function This.FullSide(cell, window)
  window = hs.window.focusedWindow()
  grid = hs.grid.get(window)
  if (grid == This.screenPositions.midleft or grid == This.screenPositions.left) then
     This.moveWindowToPosition(This.screenPositions.fullleft)
  end
  if (grid == This.screenPositions.midright or grid == This.screenPositions.right) then
     This.moveWindowToPosition(This.screenPositions.fullright)
  end
end

return This