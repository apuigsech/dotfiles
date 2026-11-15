#!/bin/bash

source ../../lib/logger
source ../../lib/utils

# Global tool versions are pinned in config.toml, linked to
# ~/.config/mise/config.toml and installed by setup.dotbot.
if ! has_cmd mise; then
    log_error "mise is not installed"
    exit 1
fi
