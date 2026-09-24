cask "claude-notch-bar" do
  version "0.2.0"
  # Placeholder — overwritten automatically by .github/workflows/release.yml on every tagged release.
  sha256 "98436161cb696c700ee920ea978735dcdda8cff132f073e2e32c77bc695543e0"

  url "https://github.com/Lixeas/ClaudeNotchBar/releases/download/v#{version}/ClaudeNotchBar-#{version}.dmg"
  name "ClaudeNotchBar"
  desc "Menu bar app that monitors Anthropic API credit usage"
  homepage "https://github.com/Lixeas/ClaudeNotchBar"

  depends_on macos: ">= :ventura"

  app "ClaudeNotchBar.app"

  zap trash: [
    "~/Library/Preferences/com.lixeas.claudenotchbar.plist",
  ]
end
