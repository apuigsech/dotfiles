# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A dotfiles management system built on [Dotbot](https://github.com/anishathalye/dotbot) with a plugin-based architecture. The main entry point is the `./dotfiles` CLI (a bash script), which provides commands for init, install, uninstall, and status.

The repo is intended to be cloned to `~/.dotfiles` and manages system configuration via symlinks and setup scripts.

## Commands

```bash
./dotfiles init                  # Initialize dotbot submodule and run base config
./dotfiles install --all         # Install all plugins
./dotfiles install brew zsh      # Install specific plugins
./dotfiles uninstall --all       # Remove all plugin symlinks
./dotfiles uninstall brew        # Remove specific plugin
./dotfiles status                # Check plugin installation status
```

Flags: `--debug`, `--strict`, `--fail-fast`, `--verbose`, `--quiet`

There are no tests, linting, or build commands.

## Architecture

### Entry Point

`./dotfiles` - Main CLI script. Sources all libraries from `lib/`, defines the plugin list in `DOTFILES_PLUGINS`, and dispatches to `cmd_init`, `cmd_install`, `cmd_uninstall`, or `cmd_status`.

### Library System (`lib/`)

Bash libraries with include-guard pattern (`[[ $LIB_INCLUDED ]] && return`). All depend on `BASE_DIR` being set. Source order matters - `logger` must load first.

| Library    | Purpose |
|------------|---------|
| `logger`   | Log levels (debug/info/warn/error), file logging to `~/.dotfiles/logs/`, color output |
| `errors`   | Error tracking, fail-fast/strict/debug modes, `require()` for dependency checks |
| `progress` | Spinner animations, progress bars, `run_task()` wrapper |
| `utils`    | `has_cmd()`, `source_dir()`, `prepend_path()`, platform detection (`is_macos`/`is_linux`/`is_wsl`) |
| `dotbot`   | Dotbot binary wrapper (`dotbot/bin/dotbot`), config validation |
| `brew`     | Homebrew install/update, package installation from `.lst` files |
| `uninstall`| Parses dotbot YAML configs to reverse symlinks and clean directories |

### Plugin System (`plugins/`)

Each plugin is a directory under `plugins/` containing one or both of:
- **`setup.sh`** - Bash script for custom installation logic (e.g., brew plugin installs packages)
- **`setup.dotbot`** - YAML config for Dotbot symlink/create operations
- **`uninstall.sh`** - Optional custom uninstall script

Registered plugins (in `DOTFILES_PLUGINS` array in `./dotfiles`): `brew`, `shell`, `zsh`, `direnv`, `hammerspoon`, `configs`, `bluereset`, `renicer`, `cursor`

Plugin execution flow: `run_plugin()` enters the plugin directory, runs `setup.sh` first, then `setup.dotbot` via dotbot binary.

### Shell Config Chain

`.zshrc` sources `lib/utils` from `DOTFILES_DIR` (~/.dotfiles), then loads Oh My Zsh + Powerlevel10k, then sources `.shellrc`. `.shellrc` calls `source_dir` on `~/.aliases`, `~/.env`, `~/.paths`, and `~/.shell` (which are symlinks created by the `shell` and `direnv` plugins).

### Configuration

`config/dotfiles.conf` - Key-value config file for logging, error handling, security, cache, brew, and plugin settings.

### Dotbot Submodule

`dotbot/` is a git submodule pointing to `https://github.com/anishathalye/dotbot`. Binary at `dotbot/bin/dotbot`.

## Conventions

- All bash libraries use include guards to prevent double-sourcing
- Libraries reference `${BASE_DIR}` for path resolution (set by the main `./dotfiles` script)
- Plugin `setup.sh` scripts source libraries via relative paths (`../../lib/logger`)
- Dotbot configs use YAML with `link`, `create`, and `shell` directives
- Package lists for brew use `.lst` files (one package per line, `#` for comments)
- Logs go to `~/.dotfiles/logs/`
