# Brew Plugin

Installs Homebrew if it is missing and then installs packages from Brewfiles
with `brew bundle`.

## Files

| File | Contents |
|---|---|
| `Brewfile` | Base: always installed |
| `Brewfile.ai` | `ai` profile: local inference, AI assistants |
| `Brewfile.dev` | `dev` profile: languages, containers, dev tools |
| `Brewfile.personal` | `personal` profile: communication, media, personal utilities |
| `Brewfile.vscode` | `vscode` profile: VS Code extensions |
| `setup.sh` | Installs Homebrew, then the base Brewfile plus the active profiles |

## Profiles

The base `Brewfile` is always installed. Each active profile adds
`Brewfile.<profile>`. The active list is read from, last one wins:

1. `brew.profiles` in `config/dotfiles.conf` (committed default: all profiles)
2. `brew.profiles` in `config/dotfiles.local.conf` (per machine, gitignored)
3. the `DOTFILES_BREW_PROFILES` environment variable

```bash
# A work machine without the personal apps:
echo 'brew.profiles=ai,dev,vscode' >> config/dotfiles.local.conf

# One-off run with a different selection (empty = base only):
DOTFILES_BREW_PROFILES=dev ./dotfiles install brew
```

A new profile is just a new `Brewfile.<name>` added to the list.

## Drift detection

`./dotfiles doctor` compares the active Brewfiles with what is installed:

- **Declared but not installed**: from `brew bundle check`. Fix with
  `./dotfiles install brew`.
- **Installed but not declared**: formulae installed on request
  (`brew leaves --installed-on-request`, so dependencies are not listed) and
  casks that no active Brewfile mentions. Add them to a Brewfile or uninstall
  them. The dotfiles only report this; they never uninstall anything.
