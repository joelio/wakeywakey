import Foundation
import ServiceManagement

struct LaunchAtLogin {
    static var isEnabled: Bool {
        get {
            if #available(macOS 13.0, *) {
                return SMAppService.mainApp.status == .enabled
            } else {
                // For older macOS versions
                return UserDefaults.standard.bool(forKey: "launchAtStartup")
            }
        }
        set {
            if #available(macOS 13.0, *) {
                do {
                    if newValue {
                        if SMAppService.mainApp.status == .enabled {
                            try SMAppService.mainApp.unregister()
                        }
                        try SMAppService.mainApp.register()
                    } else {
                        try SMAppService.mainApp.unregister()
                    }
                } catch {
                    print("Failed to \(newValue ? "register" : "unregister") app for launch at login: \(error.localizedDescription)")
                }
            } else {
                // For older macOS versions (10.11+)
                UserDefaults.standard.set(newValue, forKey: "launchAtStartup")
                
                // Use a simpler approach for older macOS versions
                // that doesn't rely on deprecated APIs
                let appURL = Bundle.main.bundleURL
                
                // Use AppleScript to manage login items
                let task = Process()
                task.launchPath = "/usr/bin/osascript"
                
                if newValue {
                    // Add to login items
                    task.arguments = [
                        "-e",
                        "tell application \"System Events\" to make login item at end with properties {path:\"\(appURL.path)\", hidden:false}"
                    ]
                } else {
                    // Remove from login items
                    task.arguments = [
                        "-e",
                        "tell application \"System Events\" to delete login item \"\(Bundle.main.bundleIdentifier ?? "")\" if it exists"
                    ]
                }
                
                do {
                    try task.run()
                } catch {
                    print("Failed to manage login items: \(error)")
                }
            }
        }
    }
}
