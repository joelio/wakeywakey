# Wakey Wakey

A native macOS menu bar app that prevents your Mac from sleeping using the `caffeinate` command.

<!-- Add a screenshot once available -->
<!-- ![Wakey Wakey App](screenshots/app-preview.png) -->

## Features

- Prevent your Mac from sleeping with just a click
- Choose from quick duration presets (15 min, 30 min, 1 hour, 2 hours, indefinite)
- Set custom durations in minutes
- Fine-grained control over what to prevent:
  - Display sleep
  - Disk sleep
  - System sleep
- Launch at startup option
- Clean, native macOS menu bar interface
- Minimal resource usage

## Installation

### Option 1: Direct Download

1. Download the latest release from the [Releases](https://github.com/joelio/wakeywakey/releases) page
2. Open the DMG file and drag Wakey Wakey to your Applications folder
3. Launch Wakey Wakey from your Applications folder

### Option 2: Homebrew

```bash
brew install joelio/wakey-wakey/wakey-wakey
```

## Usage

1. Click the menu bar icon (moon icon when inactive, sun icon when active)
2. Select a preset duration or enter a custom duration
3. Configure which sleep modes to prevent (display, disk, or system sleep)
4. Click "Start" to activate
5. Optionally, set up a schedule to automatically activate during work hours

The menu bar icon will change to indicate the active state, and you'll see a countdown timer showing the remaining time until your Mac can sleep again.

## Building from Source

### Requirements

- macOS 11.0+
- Xcode 13.0+ or Swift 5.5+

### Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/joelio/wakeywakey.git
   cd wakeywakey
   ```

2. Build using Swift Package Manager:
   ```bash
   swift build
   ```

3. Or open and build with Xcode:
   ```bash
   xed .
   ```
   Then build and run the app (⌘+R)

## How It Works

Wakey Wakey uses macOS's native `caffeinate` command-line utility to prevent sleep. This is the same utility that the built-in "caffeinate" command uses, but with a friendly GUI and additional features.

### Key Features

- **Menu Bar Integration**: Always accessible but never in the way
- **Scheduling**: Set up automatic activation during work hours
- **Fine-grained Control**: Choose which types of sleep to prevent
- **Presets**: Quick access to common durations
- **Custom Duration**: Set any time in minutes
- **Launch at Login**: Automatically start with your Mac

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Apple for the SF Symbols used in the app
- The Swift and SwiftUI teams for making native app development a joy

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
