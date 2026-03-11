# TermBar Design Spec

## Purpose
macOS menu bar app for quick-launching CLI AI tools (Claude, Codex, Kimi, Gemini) in Terminal.app.

## Menu Bar
- Icon: `terminal.fill` SF Symbol, template mode
- Global hotkey to open: Ctrl+Opt+T

## Dropdown (NSMenu)
Flat list, 4 items:

| # | Tool | SF Symbol | Command | Shortcut |
|---|------|-----------|---------|----------|
| 1 | Claude | `sparkles` | `claude --dangerously-skip-permissions` | Cmd+1 |
| 2 | Codex | `chevron.left.forwardslash.chevron.right` | `codex` | Cmd+2 |
| 3 | Kimi | `brain.head.profile` | `kimi-cli` | Cmd+3 |
| 4 | Gemini | `circle.hexagongrid` | `gemini` | Cmd+4 |

Separator, then:
- Quit TermBar (Cmd+Q)

## Interaction
Click or shortcut → launches Terminal.app with an AppleScript that opens a new window and runs the CLI command.

## Tech
- Swift 6, macOS 13+, SPM
- `NSStatusItem` + `NSMenu`
- `Carbon` hotkey API (same pattern as CopyPro)
- `NSAppleScript` or `Process` to launch Terminal commands
- `LSUIElement = true` (no dock icon)
