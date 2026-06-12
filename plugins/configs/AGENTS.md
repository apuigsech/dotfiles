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

## Procedures

Reusable, agent-runnable procedures. Each one describes a repeatable task: when to run it, the steps to follow, and what to deliver. Follow them as written unless the user asks otherwise.

### Analyze and propose a cleanup of `~/Downloads`

**When:** the user asks to clean, tidy, review, or audit the Downloads folder.

**Goal:** produce a cleanup proposal — never delete or move anything without explicit user approval.

**Steps:**
1. Inventory `~/Downloads`: list files and directories with size and modification date (e.g. `ls -lahT ~/Downloads`). Get total size with `du -sh ~/Downloads`.
2. Classify items into buckets:
   - **Installers / disk images** (`.dmg`, `.pkg`, app `.zip`) — usually safe to remove after install.
   - **Stale** — not modified in 90+ days.
   - **Duplicates** — same name with `(1)`, `(2)` suffixes, or identical size/content.
   - **Large** — above ~100 MB, flag for review.
   - **Misplaced** — source code, documents, or media that belong elsewhere (e.g. repos → `~/Develop/{forge}/{owner}/{repo}`).
   - **Keep / unclear** — recent or ambiguous items; leave for the user to decide.
3. Present a summary table grouped by bucket, with total reclaimable space per bucket and a recommended action per item (delete, move to `<path>`, keep).
4. Wait for explicit approval before executing any deletion or move. Prefer moving misplaced files to their correct location over deleting.

**Deliverable:** a categorized proposal with reclaimable-space estimate. No destructive action until the user confirms.
