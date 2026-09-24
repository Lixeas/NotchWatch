cask "claude-notch-bar" do
  version "0.1.0"
  # Placeholder — overwritten automatically by .github/workflows/release.yml on every tagged release.
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"

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
