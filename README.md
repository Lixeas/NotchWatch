<img src="NotchWatch/Resources/Images/notchwatch-corbeau-16-modified.svg" width="64" height="64" alt="NotchWatch logo">

# NotchWatch

[![Test](https://github.com/Lixeas/NotchWatch/actions/workflows/test.yml/badge.svg)](https://github.com/Lixeas/NotchWatch/actions/workflows/test.yml)

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
brew tap Lixeas/notchwatch https://github.com/Lixeas/NotchWatch
brew install --cask notch-watch
```

This installs the latest signed `.dmg` from [GitHub Releases](https://github.com/Lixeas/NotchWatch/releases) and keeps a Homebrew-managed `NotchWatch.app` in `/Applications`. To update: `brew upgrade --cask notch-watch`.

### Option 2 — Manual download

1. Download the latest `NotchWatch-X.Y.Z.dmg` from the [Releases page](https://github.com/Lixeas/NotchWatch/releases).
2. Open the `.dmg` and drag `NotchWatch.app` into `Applications`.
3. First launch: the app isn't notarized (no Apple Developer Program membership), so Gatekeeper will block it. Either:
   - Right-click the app → **Open** → confirm in the dialog, or
   - Run `xattr -cr /Applications/NotchWatch.app` in Terminal once, then open normally.

### Option 3 — Build from source

```sh
git clone https://github.com/Lixeas/NotchWatch.git
cd NotchWatch
swift build -c release
.build/release/NotchWatch
```

## Usage

1. Launch the application — it lives only in the menu bar (no Dock icon).
2. Click the menu bar pill to see credit consumption, refresh, or open **Settings**.
3. In Settings: paste a manual auth token if the automatic one expired, change the refresh interval, or enable launch at login.

### Keychain access prompt

On first launch (and sometimes again after), macOS asks for your login password to let NotchWatch read Claude Code's stored credentials. **Click "Always Allow", not "Allow"** — "Allow" only grants a one-time read, so the next refresh prompts again.

If you're building from source with `swift run`/`swift build`, expect it to re-prompt after every rebuild even if you picked "Always Allow": each dev build gets a new ad-hoc code signature, and the Keychain's permanent grant is tied to that signature. This goes away once you run the properly signed `.app` (Homebrew or the release `.dmg`).

### Auth token expired

NotchWatch reuses Claude Code CLI's own login, so the fix is usually one command:

```sh
claude login
```

This refreshes the token Claude Code stores in the Keychain — NotchWatch picks it up automatically on the next refresh, no further action needed.

If you can't run `claude login` (no CLI on this machine, different account, etc.), paste a token manually in **Settings → Jeton d'authentification**:

1. Get a fresh OAuth access token — either from `claude login` on any machine, or by extracting the one Claude Code already has stored:
   ```sh
   security find-generic-password -s "Claude Code-credentials" -w | python3 -c "import json,sys; print(json.load(sys.stdin)['claudeAiOauth']['accessToken'])"
   ```
2. Paste it into the token field in Settings — it saves automatically as you type, no button to click.
3. Leave the field empty to go back to the automatic Claude Code token.

Bonus: once a manual token is set, NotchWatch reads it from its own Keychain entry instead of Claude Code's — no more cross-app Keychain permission prompts.

## Requirements

- macOS 13.0 (Ventura) or later
- To build from source: Swift 5.9+ / Xcode 15+

## Development

- `swift build` / `swift test` — build and run the unit tests locally (or let the [Test workflow](.github/workflows/test.yml) do it on a real macOS runner on every push/PR).
- `.github/workflows/release.yml` — tag `vX.Y.Z` and push it (or run manually via `workflow_dispatch`) to build the `.app`, package a `.dmg`, publish a GitHub Release, and bump `Casks/notch-watch.rb` automatically.

## Contributing

Contributions are welcome. Please follow the standard GitHub flow.

## License

This project is licensed under the MIT License.
