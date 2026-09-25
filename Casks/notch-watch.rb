cask "notch-watch" do
  version "0.3.1"
  # Placeholder — overwritten automatically by .github/workflows/release.yml on every tagged release.
  sha256 "485351b04369ec002d99cd01fde12f4cb8b915840d45b1dc074072819f07fb76"

  url "https://github.com/Lixeas/NotchWatch/releases/download/v#{version}/NotchWatch-#{version}.dmg"
  name "NotchWatch"
  desc "Menu bar app that monitors Anthropic API credit usage"
  homepage "https://github.com/Lixeas/NotchWatch"

  depends_on macos: :ventura

  app "NotchWatch.app"

  zap trash: [
    "~/Library/Preferences/com.lixeas.notchwatch.plist",
  ]
end
