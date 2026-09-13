# Spotify Global Hotkeys

A lightweight Windows utility that adds global Spotify keyboard shortcuts for playback and Spotify-only volume control.

The hotkeys continue working while Spotify is minimized or while another application or game is in focus.

## Features

- Global Play/Pause control
- Global Next Track control
- Global Previous Track control
- Spotify-only volume adjustment
- Automatically detects Spotify on the user's PC
- Supports Microsoft Store and standard desktop Spotify installations
- Automatically launches Spotify if it is not already running
- Forces Spotify's internal volume to 100% before enabling volume control
- Automatically closes the hotkey process when Spotify exits
- Portable package with no AutoHotkey installation required for normal use

## Default Hotkeys

| Hotkey | Action |
|---|---|
| `Ctrl + Alt + Space` | Play / Pause |
| `Ctrl + Alt + Right Arrow` | Next Track |
| `Ctrl + Alt + Left Arrow` | Previous Track |
| `Ctrl + Alt + Up Arrow` | Spotify Volume +5% |
| `Ctrl + Alt + Down Arrow` | Spotify Volume -5% |

## How It Works

Spotify has its own internal volume control in addition to the Windows application volume.

When the launcher starts:

1. Spotify is automatically located on the computer.
2. Spotify is launched if it is not already running.
3. The Spotify window is detected and activated.
4. Spotify's internal volume is forced to 100%.
5. `SpotifyHotkeys.exe` starts.
6. The global hotkeys become active.
7. Volume hotkeys adjust Spotify's Windows audio session using SoundVolumeView.
8. When Spotify fully exits, `SpotifyHotkeys.exe` automatically exits as well.

This allows Spotify volume to be controlled independently from the Windows master volume.

## Installation

### Recommended Method

1. Download the latest release ZIP from the GitHub **Releases** page.
2. Extract the ZIP to a folder.
3. Open the extracted folder.
4. Double-click:

```text
Launch Spotify Hotkeys.cmd
