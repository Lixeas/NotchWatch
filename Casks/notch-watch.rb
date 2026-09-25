cask "notch-watch" do
  version "0.3.0"
  # Placeholder — overwritten automatically by .github/workflows/release.yml on every tagged release.
  sha256 "8d8bc24ade1c4685cd0789dd2eecad2f1ea2a5d4e45dd739c6a46412f3f1b1fd"

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
