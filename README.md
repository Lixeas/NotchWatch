# ClaudeNotchBar

[![Test](https://github.com/Lixeas/ClaudeNotchBar/actions/workflows/test.yml/badge.svg)](https://github.com/Lixeas/ClaudeNotchBar/actions/workflows/test.yml)

A macOS menu bar application for monitoring Anthropic API credit consumption.

## Features

- Menu bar icon shown as a progress pill (color-coded: green / orange / red as you approach your limit)
- Real-time display of Anthropic API credit usage, 5h/7-day rate-limit windows
- Secure OAuth token retrieval from the macOS Keychain (reuses Claude Code's login), with a manual override in Settings if it expires
- Automatic refresh on a configurable interval
- Launch at login (optional)

## Installation

### Option 1 — Homebrew (recommended)

```sh
brew tap Lixeas/claudenotchbar https://github.com/Lixeas/ClaudeNotchBar
brew install --cask claude-notch-bar
```

This installs the latest signed `.dmg` from [GitHub Releases](https://github.com/Lixeas/ClaudeNotchBar/releases) and keeps a Homebrew-managed `ClaudeNotchBar.app` in `/Applications`. To update: `brew upgrade --cask claude-notch-bar`.

### Option 2 — Manual download

1. Download the latest `ClaudeNotchBar-X.Y.Z.dmg` from the [Releases page](https://github.com/Lixeas/ClaudeNotchBar/releases).
2. Open the `.dmg` and drag `ClaudeNotchBar.app` into `Applications`.
3. First launch: the app isn't notarized (no Apple Developer Program membership), so Gatekeeper will block it. Either:
   - Right-click the app → **Open** → confirm in the dialog, or
   - Run `xattr -cr /Applications/ClaudeNotchBar.app` in Terminal once, then open normally.

### Option 3 — Build from source

```sh
git clone https://github.com/Lixeas/ClaudeNotchBar.git
cd ClaudeNotchBar
swift build -c release
.build/release/ClaudeNotchBar
```

## Usage

1. Launch the application — it lives only in the menu bar (no Dock icon).
2. Click the menu bar pill to see credit consumption, refresh, or open **Settings**.
3. In Settings: paste a manual auth token if the automatic one expired, change the refresh interval, or enable launch at login.

## Requirements

- macOS 13.0 (Ventura) or later
- To build from source: Swift 5.9+ / Xcode 15+

## Development

- `swift build` / `swift test` — build and run the unit tests locally (or let the [Test workflow](.github/workflows/test.yml) do it on a real macOS runner on every push/PR).
- `.github/workflows/release.yml` — tag `vX.Y.Z` and push it (or run manually via `workflow_dispatch`) to build the `.app`, package a `.dmg`, publish a GitHub Release, and bump `Casks/claude-notch-bar.rb` automatically.

## Contributing

Contributions are welcome. Please follow the standard GitHub flow.

## License

This project is licensed under the MIT License.
