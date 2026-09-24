cask "notch-watch" do
  version "0.2.0"
  # Placeholder — overwritten automatically by .github/workflows/release.yml on every tagged release.
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"

  url "https://github.com/Lixeas/NotchWatch/releases/download/v#{version}/NotchWatch-#{version}.dmg"
  name "NotchWatch"
  desc "Menu bar app that monitors Anthropic API credit usage"
  homepage "https://github.com/Lixeas/NotchWatch"

  depends_on macos: ">= :ventura"

  app "NotchWatch.app"

  zap trash: [
    "~/Library/Preferences/com.lixeas.notchwatch.plist",
  ]
end
