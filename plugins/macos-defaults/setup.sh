#!/bin/bash

source ../../lib/logger
source ../../lib/utils

if ! is_macos; then
    log_info "Skipping macOS defaults: not running on macOS"
    exit 0
fi

log_info "Applying macOS defaults..."

###############################################################################
# General UI/UX                                                               #
###############################################################################

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" " 2>/dev/null || true

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Disable automatic capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

###############################################################################
# Keyboard & Input                                                            #
###############################################################################

# Set a fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Enable full keyboard access for all controls (Tab in dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

###############################################################################
# Trackpad                                                                    #
###############################################################################

# Enable tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Light click threshold
defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 0
defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold -int 0

# Enable three finger drag
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

# Disable three finger gestures (conflict with three finger drag)
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture -int 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture -int 0

# Use four fingers for swipe between desktops and Mission Control
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerHorizSwipeGesture -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerVertSwipeGesture -int 2

###############################################################################
# Finder                                                                      #
###############################################################################

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Use column view in all Finder windows by default
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

###############################################################################
# Dock                                                                        #
###############################################################################

# Position on the left
defaults write com.apple.dock orientation -string "left"

# Set the icon size of Dock items
defaults write com.apple.dock tilesize -int 48

# Enable magnification
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock largesize -int 30

# Minimize windows using scale effect
defaults write com.apple.dock mineffect -string "scale"

# Minimize windows into application icon
defaults write com.apple.dock minimize-to-application -bool true

# Disable launch animation
defaults write com.apple.dock launchanim -bool false

# Don't show recent applications in Dock
defaults write com.apple.dock show-recents -bool false

# Don't show process indicators
defaults write com.apple.dock show-process-indicators -bool false

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0

# Speed up the animation when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float 0.3

# Hot corner: bottom right → Quick Note
defaults write com.apple.dock wvous-br-corner -int 14

# Dock apps (requires dockutil)
if has_cmd dockutil; then
    log_info "Configuring dock apps..."
    dockutil --remove all --no-restart

    dock_apps=(
        "/Applications/Telegram.app"
        "/Applications/Arc.app"
        "/Applications/iTerm.app"
        "/Applications/ChatGPT Atlas.app"
    )

    for app in "${dock_apps[@]}"; do
        if [[ -d "$app" ]]; then
            dockutil --add "$app" --no-restart
        else
            log_warn "Dock app not found: $app"
        fi
    done
else
    log_warn "dockutil not found, skipping dock apps setup"
fi

###############################################################################
# Safari                                                                      #
###############################################################################

# Enable Safari's developer extras
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true

# Enable "Do Not Track"
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

###############################################################################
# Activity Monitor                                                            #
###############################################################################

# Show the main window when launching Activity Monitor
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# Show all processes in Activity Monitor
defaults write com.apple.ActivityMonitor ShowCategory -int 0

###############################################################################
# TextEdit                                                                    #
###############################################################################

# Use plain text mode for new TextEdit documents
defaults write com.apple.TextEdit RichText -int 0

###############################################################################
# Loopback aliases                                                            #
###############################################################################

PLIST_SRC="$(dirname "$0")/com.dotfiles.loopback-aliases.plist"
PLIST_DST="/Library/LaunchDaemons/com.dotfiles.loopback-aliases.plist"

if [[ -f "$PLIST_SRC" ]] && [[ ! -f "$PLIST_DST" ]]; then
    log_info "Installing loopback alias LaunchDaemon (127.0.0.2)..."
    sudo cp "$PLIST_SRC" "$PLIST_DST"
    sudo chown root:wheel "$PLIST_DST"
    sudo chmod 644 "$PLIST_DST"
    sudo launchctl load "$PLIST_DST"
fi

###############################################################################
# Local DNS (/etc/hosts)                                                      #
###############################################################################

hosts_entries=(
    "127.0.0.2 ollama.local"
)

for entry in "${hosts_entries[@]}"; do
    if ! grep -qF "$entry" /etc/hosts; then
        log_info "Adding /etc/hosts entry: $entry"
        echo "$entry" | sudo tee -a /etc/hosts >/dev/null
    fi
done

###############################################################################
# Apply changes                                                               #
###############################################################################

log_info "Restarting affected applications..."
for app in "Finder" "Dock" "Safari" "SystemUIServer"; do
    killall "$app" &>/dev/null || true
done

log_info "macOS defaults applied. Some changes may require a logout/restart."
