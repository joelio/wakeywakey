cask "wakey-wakey" do
  version "1.0.0"
  sha256 :no_check

  url "https://github.com/joelio/wakeywakey/releases/download/v#{version}/WakeyWakey.dmg"
  name "Wakey Wakey"
  desc "Keep your Mac awake for specified periods"
  homepage "https://github.com/joelio/wakeywakey"

  app "WakeyWakey.app"

  zap trash: [
    "~/Library/Application Support/WakeyWakey",
    "~/Library/Preferences/com.joelio.wakeywakey.plist",
    "~/Library/Caches/com.joelio.wakeywakey",
    "~/Library/Logs/WakeyWakey"
  ]
end
