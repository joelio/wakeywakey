cask "wakey-wakey" do
  version "1.0.0"
  # After creating a GitHub release, update this SHA256 with the actual value
  # You can get it by running: shasum -a 256 path/to/WakeyWakey.dmg
  sha256 "replace_with_actual_sha256_after_first_release"

  url "https://github.com/joelio/wakeywakey/releases/download/v#{version}/WakeyWakey.dmg"
  name "Wakey Wakey"
  desc "Menu bar app to prevent your Mac from sleeping using caffeinate"
  homepage "https://github.com/joelio/wakeywakey"

  app "WakeyWakey.app"

  uninstall quit: "com.joelio.WakeyWakey"

  zap trash: [
    "~/Library/Application Support/WakeyWakey",
    "~/Library/Preferences/com.joelio.WakeyWakey.plist",
    "~/Library/Caches/com.joelio.WakeyWakey",
    "~/Library/Saved Application State/com.joelio.WakeyWakey.savedState"
  ]
end
