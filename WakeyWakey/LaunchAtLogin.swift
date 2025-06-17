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
                // For older macOS versions
                UserDefaults.standard.set(newValue, forKey: "launchAtStartup")
                
                let bundleId = Bundle.main.bundleIdentifier ?? ""
                if let loginItems = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil)?.takeRetainedValue() {
                    if newValue {
                        // Add to login items
                        if let appURL = Bundle.main.bundleURL as CFURL? {
                            LSSharedFileListInsertItemURL(
                                loginItems,
                                kLSSharedFileListItemLast.takeRetainedValue(),
                                nil,
                                nil,
                                appURL,
                                nil,
                                nil
                            )
                        }
                    } else {
                        // Remove from login items
                        if let loginItemsArray = LSSharedFileListCopySnapshot(loginItems, nil)?.takeRetainedValue() as? [LSSharedFileListItem] {
                            for loginItem in loginItemsArray {
                                if let itemURL = LSSharedFileListItemCopyResolvedURL(loginItem, 0, nil)?.takeRetainedValue() as URL?,
                                   itemURL.absoluteString == Bundle.main.bundleURL.absoluteString {
                                    LSSharedFileListItemRemove(loginItems, loginItem)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
