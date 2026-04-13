# AGENTS.md — Home Directory Operations

This file provides context for AI agents working within the home directory structure.

## Purpose
Agents operating here manage personal infrastructure: dotfiles, system configuration, directory organization, and tooling setup. This is NOT a project repository — it's the user's workstation environment.

## Directory Layout

```
~/
├── Develop/                         # All source code
│   ├── github.com/{owner}/{repo}    # GitHub repos (Go-style paths)
│   ├── gitlab.com/{owner}/{repo}    # GitLab repos
│   └── tmp/                         # Throwaway experiments
├── .dotfiles/                       # Dotfiles repo (github.com/apuigsech/dotfiles)
├── bin/                             # Personal scripts (managed by dotfiles)
├── .ssh/                            # SSH keys and config (managed by dotfiles)
├── .oh-my-zsh/                      # Oh My Zsh (installed by dotfiles zsh plugin)
├── .aliases/                        # Shell aliases (symlink to dotfiles)
├── .env/                            # Environment variables (symlink to dotfiles)
├── .paths/                          # PATH entries (symlink to dotfiles)
├── .shell/                          # Shell plugins (symlink to dotfiles)
└── .functions/                      # Shell functions (symlink to dotfiles)
```

## Conventions

- **Source code** always goes under `~/Develop/{forge}/{owner}/{repo}`. Never clone repos directly under `~`.
- **Dotfiles** are managed via `~/.dotfiles/dotfiles` CLI. Do not manually edit symlinked files — edit the source in `~/.dotfiles/plugins/`.
- **Shell config chain**: `.zshrc` → `.shellrc` → sources `.aliases/`, `.env/`, `.paths/`, `.shell/` via `source_dir`.
- **Git identity** is context-dependent via `includeIf` in `.gitconfig`. Personal by default, overridden per org path.
- **Homebrew** packages are declared in `~/.dotfiles/plugins/brew/Brewfile*` (base, dev, personal).

## Constraints

- Do not create files or directories directly in `~` unless they are dotfiles or standard XDG paths.
- Do not modify symlinked config files — trace them back to `~/.dotfiles/plugins/` and edit there.
- Do not install packages outside of Homebrew/Brewfile unless there's a specific reason (e.g., rustup, language-specific managers).
- The `~/Develop/tmp/` directory is ephemeral — do not store anything important there.
