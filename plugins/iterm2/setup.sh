#!/bin/bash

source ../../lib/logger
source ../../lib/utils

if ! is_macos; then
    log_info "Skipping iTerm2 setup: not running on macOS"
    exit 0
fi

# Set default profile font to MesloLGS Nerd Font Mono
FONT="MesloLGSNerdFontMono-Regular 13"
log_info "Setting iTerm2 default profile font to $FONT..."
/usr/libexec/PlistBuddy -c "Set ':New Bookmarks':0:'Normal Font' '$FONT'" \
    ~/Library/Preferences/com.googlecode.iterm2.plist 2>/dev/null || \
    log_warn "Could not set iTerm2 default font (iTerm2 may not be installed yet)"
