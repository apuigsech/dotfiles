-- Clipboard Manager Module (DISABLED BY DEFAULT)
-- Manages clipboard history and provides quick access to previous items

local This = {}

-- Load configuration
local config = require('config').clipboardManager or {}
local displayConfig = require('config').display

-- Module state
local clipboardHistory = {}
local maxHistorySize = config.maxHistorySize or 20
local clipboardWatcher = nil
local chooser = nil

-- Initialize clipboard manager
function This.init()
  if not config.enabled then
    return
  end

  -- Create chooser for clipboard history
  chooser = hs.chooser.new(This.pasteFromHistory)
  chooser:placeholderText("Search clipboard history...")
  chooser:searchSubText(true)
  chooser:width(20)
  chooser:rows(8)

  -- Start watching clipboard
  This.startWatching()

  print("Clipboard manager initialized")
end

-- Start watching clipboard changes
function This.startWatching()
  if clipboardWatcher then
    clipboardWatcher:stop()
  end

  clipboardWatcher = hs.pasteboard.watcher.new(function()
    local currentClipboard = hs.pasteboard.getContents()
    if currentClipboard and currentClipboard ~= "" then
      This.addToHistory(currentClipboard)
    end
  end)

  clipboardWatcher:start()
end

-- Add item to clipboard history
function This.addToHistory(content)
  -- Remove if already exists
  for i, item in ipairs(clipboardHistory) do
    if item.content == content then
      table.remove(clipboardHistory, i)
      break
    end
  end

  -- Add to beginning
  table.insert(clipboardHistory, 1, {
    content = content,
    timestamp = os.time(),
    preview = This.createPreview(content)
  })

  -- Limit history size
  if #clipboardHistory > maxHistorySize then
    table.remove(clipboardHistory, #clipboardHistory)
  end

  -- Update chooser
  if chooser then
    chooser:choices(This.getChoices())
  end
end

-- Create preview text for display
function This.createPreview(content)
  local preview = content:gsub("\n", " "):gsub("\r", " ")
  local previewLength = config.previewLength or 60
  if #preview > previewLength then
    preview = preview:sub(1, previewLength - 3) .. "..."
  end
  return preview
end

-- Get choices for chooser
function This.getChoices()
  local choices = {}
  for i, item in ipairs(clipboardHistory) do
    table.insert(choices, {
      text = item.preview,
      subText = os.date("%H:%M:%S", item.timestamp),
      content = item.content,
      index = i
    })
  end
  return choices
end

-- Paste from history
function This.pasteFromHistory(choice)
  if choice and choice.content then
    hs.pasteboard.setContents(choice.content)
    if displayConfig.showAlerts then
      hs.alert.show("Clipboard item selected", 1)
    end
  end
end

-- Show clipboard history
function This.showHistory()
  if not config.enabled then
    hs.alert.show("Clipboard manager is disabled")
    return
  end

  if chooser then
    chooser:show()
  end
end

-- Clear clipboard history
function This.clearHistory()
  clipboardHistory = {}
  if chooser then
    chooser:choices({})
  end
  if displayConfig.showAlerts then
    hs.alert.show("Clipboard history cleared")
  end
end

-- Get clipboard history
function This.getHistory()
  return clipboardHistory
end

-- Stop clipboard manager
function This.stop()
  if clipboardWatcher then
    clipboardWatcher:stop()
    clipboardWatcher = nil
  end

  if chooser then
    chooser:hide()
  end
end

return This
