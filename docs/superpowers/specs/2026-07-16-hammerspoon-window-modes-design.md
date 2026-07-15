# Hammerspoon window-management modes — design

Date: 2026-07-16
Status: Approved (design), pending implementation plan

## Goal

Let the Hammerspoon window manager have several **modes** that change how the
arrow keys place the focused window — e.g. a 3-column mode and a 4-column mode.
The active mode is chosen per monitor category and switched manually with a
keyboard chord.

This generalizes what already exists: today `getScreenMode()` auto-detects
`single_monitor` vs `ultra_wide` by aspect ratio, and `KEYMODES` maps the arrow
keys to different position functions for each. We turn that hard-coded pair into
a small registry of named modes plus a manual switcher.

## Concept

- A **mode** = a grid width + a mapping of the movement keys (← → ↑ ↓ F) to
  window placements.
- Modes are grouped into **per-monitor-category cycles**. The category of the
  focused window's screen (via `window:screen()`) selects which list of modes is
  available.
- A chord (⌘⌥⇧) **advances** through the current category's list. Each category
  **remembers its own active mode** (index), so moving a window between a laptop
  and an ultrawide keeps each monitor on its own mode.

### Monitor categories

Two categories, detected exactly as today (from the focused window's screen):

| Category    | Detection                     |
|-------------|-------------------------------|
| `normal`    | aspect ratio ≤ 2.0            |
| `ultrawide` | aspect ratio > 2.0            |

`config.windowManager.autoDetectScreens = false` continues to force `normal`.

### Mode cycles (config)

```lua
config.windowManager.modeCycles = {
  normal    = { "halves", "thirds" },   -- monitor normal
  ultrawide = { "quarters", "thirds" }, -- ultrawide (aspect > 2.0)
}
```

- Each category **starts on its first entry**: `normal` → `halves`,
  `ultrawide` → `quarters`. This reproduces today's behavior exactly.
- The lists are data — adding a future `fifths` mode is just editing this table
  (and defining the mode; see below).
- There is no separate `auto` pseudo-mode: the category picks the list, the
  remembered index picks the mode.

## Modes

Three modes ship. `halves` and `quarters` reuse today's behavior verbatim (low
risk); `thirds` is new.

### `quarters` (4-wide grid) — identical to today's `ultra_wide`

| Key | Action                                                                 |
|-----|------------------------------------------------------------------------|
| ←   | Alternate between the two left columns (col1 ↔ col0) — `SwitchLeft`     |
| →   | Alternate between the two right columns (col2 ↔ col3) — `SwitchRight`   |
| ↓   | Centered 2-col — `FullMid`                                              |
| ↑   | 2-col half on the window's current side — `FullSide`                    |
| F   | Fullscreen — `FullScreen`                                               |

### `halves` (4-wide grid) — identical to today's `single_monitor`

| Key | Action                                   |
|-----|------------------------------------------|
| ←   | Left half (cols 0-1) — `FullLeft`        |
| →   | Right half (cols 2-3) — `FullRight`      |
| ↓   | Centered half (cols 1-2) — `FullMid`     |
| ↑   | Fullscreen — `FullScreen`                |
| F   | Fullscreen — `FullScreen`                |

Note: `halves` keeps the 4-wide grid so the centered half (cols 1-2) is
expressible; the name refers to the resulting window size, not the grid width.

### `thirds` (3-wide grid) — new

| Key | Placement            | Cells        |
|-----|----------------------|--------------|
| ←   | Left third           | `[X][ ][ ]`  |
| →   | Right third          | `[ ][ ][X]`  |
| ↓   | Center third         | `[ ][X][ ]`  |
| ↑   | Two-thirds of the window's current side (left→cols 0-1, right→cols 1-2) | `[X][X][ ]` / `[ ][X][X]` |
| F   | Fullscreen           | `[X][X][X]`  |

Unlike `quarters`, ← and → do **not** alternate (each side is a single column),
so they snap directly to the left/right third.

## Trigger

- Chord: **⌘⌥⇧** (Cmd+Option+Shift), no regular key.
- Because Shift is a modifier, `hs.hotkey.bind` cannot bind this (it needs a
  non-modifier key). We use `hs.eventtap` on `flagsChanged` and fire **once when
  the flag set transitions into exactly {cmd, alt, shift}**.
- Practical UX: hold ⌘⌥ and **tap Shift** to advance the mode; each tap =
  one step. An `hs.alert` shows the newly-selected mode name.
- Accepted trade-off: modifier-only triggers can fire when that exact
  combination is entered for other purposes. Nothing else in this config uses
  ⌘⌥⇧, so this is acceptable. To avoid repeats while held, we fire only on the
  transition into the combination, not continuously.

## Architecture

### Move mode logic into the `window-management` module

Today `getScreenMode`, `KEYMODES`, and `executeKeyCommand` live in `init.lua`.
Move the mode registry, category detection, per-category state, and key dispatch
into `modules/window-management`. `init.lua` is left as pure wiring.

New module API:

- `wm.applyKey(key)` — place the focused window using the active mode for that
  window's screen category. `key` ∈ `{ "left", "right", "up", "down", "f" }`.
- `wm.cycleMode()` — advance the active mode for the focused window's screen
  category, remember the new index, and alert the mode name.
- `wm.activeModeName(category)` — introspection (used by help text / tests).

Mode definitions live in the module (like `screenPositions` today): each mode is
`{ gridWidth = N, keymap = { left = <action>, right = ..., up = ..., down = ...,
f = ... } }`, where an action is one of the existing behavior functions
(`SwitchLeft`, `FullMid`, `FullSide`, …) or a small new function for `thirds`.

Per-category state (remembered mode index) is module-level runtime state:
`modeIndex = { normal = 1, ultrawide = 1 }`. It resets to defaults on config
reload (acceptable — mode selection is ephemeral runtime state).

### Grid width

`hs.grid.setGrid` is global. Each mode declares its `gridWidth`; before placing a
window, `applyKey` sets the grid to the active mode's width. Setting the grid per
placement is cheap and keeps positions unambiguous when modes differ in width.

### `init.lua` wiring

- Arrow / F hotkeys call `wm.applyKey("left"|"right"|"up"|"down"|"f")` instead of
  the local `executeKeyCommand`.
- New: an `hs.eventtap` (created and started in `init.lua`, or exposed by the
  module and started in `init.lua`) fires `wm.cycleMode()` on the ⌘⌥⇧
  transition. Reference is retained so it is not garbage-collected.
- The ⌘⌥H help text gains a line describing ⌘⌥⇧ = switch mode.

### Config surface (`config.lua`)

- Add `config.windowManager.modeCycles` (shown above).
- No new entry in `config.hotkeys.keys` (the chord is modifier-only, handled by
  eventtap, not `hs.hotkey`). Add `config.hotkeys.modeSwitchModifiers =
  { "cmd", "alt", "shift" }` so the trigger combination stays configurable like
  the other modifier settings.

## Behavior preservation

- `normal` starting mode `halves` == today's `single_monitor` KEYMODES.
- `ultrawide` starting mode `quarters` == today's `ultra_wide` KEYMODES.
- The existing behavior functions (`SwitchLeft`, `SwitchRight`, `FullMid`,
  `FullSide`, `FullLeft`, `FullRight`, `FullScreen`) are reused unchanged for
  those two modes, so with no chord pressed the manager behaves exactly as it
  does after the previous refactor.

## Edge cases

- **No focused window**: `applyKey` / `cycleMode` show the existing "No focused
  window" alert and no-op (reuse `getFocusedWindow`).
- **Single-entry category list**: `cycleMode` wraps to the same mode (a no-op
  placement-wise) and still alerts the name.
- **Grid re-read across mode switch**: `quarters` alternation reads the window's
  current grid cell; right after a mode/grid-width change the first arrow press
  simply snaps fresh — acceptable.
- **`autoDetectScreens = false`**: category is always `normal`; only the
  `normal` list is reachable.

## Testing

Extend the existing `luajit` + `hs`-mock harness (`scratchpad/mockhs.lua`,
`test_module.lua`, `test_init.lua`):

- **Mode registry**: each mode places the focused window in the expected cells
  for ← → ↑ ↓ F, including `quarters` alternation and its absence in `thirds`.
- **Category detection**: `applyKey` uses the focused window's screen aspect
  ratio to pick the category/mode; `autoDetectScreens = false` forces `normal`.
- **Cycle + memory**: `cycleMode` advances within the current category's list,
  wraps at the end, and each category remembers its own index independently.
- **Grid width**: the grid is set to the active mode's width before placement.
- **eventtap dispatch**: simulate a `flagsChanged` transition into {cmd,alt,shift}
  and assert exactly one `cycleMode` per transition (mock the eventtap).
- **End-to-end**: real `init.lua` still loads with all features enabled.

All existing tests (13 module + 6 init) must continue to pass.

## Out of scope (YAGNI)

- Menubar indicator of the active mode (alert-on-switch only for now).
- Persisting the active mode across reloads.
- Per-physical-monitor memory beyond the two categories.
- Arbitrary user-defined modes via config data alone (new modes need a
  definition in the module); the `modeCycles` table only composes existing ones.
