import SwiftUI

@main
struct WakeyWakeyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var cafeinate: CafeinateManager?
    var scheduleManager: ScheduleManager?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        cafeinate = CafeinateManager()
        scheduleManager = ScheduleManager(cafeinateManager: cafeinate!)
        
        setupMenuBar()
        setupPopover()
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(named: "MenuBarIcon")
            button.action = #selector(togglePopover)
            button.target = self
        }
    }
    
    private func setupPopover() {
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 280, height: 380)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: ContentView(cafeinate: cafeinate!, scheduleManager: scheduleManager!)
                .environmentObject(cafeinate!)
        )
        self.popover = popover
    }
    
    @objc func togglePopover() {
        if let button = statusItem?.button {
            if popover?.isShown == true {
                popover?.performClose(nil)
            } else {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover?.contentViewController?.view.window?.makeKey()
            }
        }
    }
    
    func updateMenuBarIcon(isActive: Bool) {
        if let button = statusItem?.button {
            if isActive {
                button.image = NSImage(named: "MenuBarIconActive")
            } else {
                button.image = NSImage(named: "MenuBarIcon")
            }
        }
    }
}
