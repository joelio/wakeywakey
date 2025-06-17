import Foundation
import SwiftUI

class CafeinateManager: ObservableObject {
    @Published var isActive: Bool = false
    @Published var currentDuration: Int = 0
    @Published var remainingTime: Int = 0
    @Published var endTime: Date? = nil
    @Published var activatedBySchedule: Bool = false
    
    @AppStorage("preventDisplaySleep") var preventDisplaySleep: Bool = true
    @AppStorage("preventDiskSleep") var preventDiskSleep: Bool = false
    @AppStorage("preventSystemSleep") var preventSystemSleep: Bool = true
    
    private var cafeinateProcess: Process?
    private var timer: Timer?
    
    init() {
        // Initialize with stored preferences
    }
    
    deinit {
        deactivate()
    }
    
    func activate(minutes: Int) {
        // First deactivate any existing process
        deactivate()
        
        // Build the caffeinate command with appropriate flags
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
        
        var arguments: [String] = []
        
        if preventDisplaySleep {
            arguments.append("-d") // Prevent display sleep
        }
        
        if preventDiskSleep {
            arguments.append("-m") // Prevent disk sleep
        }
        
        if preventSystemSleep {
            arguments.append("-s") // Prevent system sleep
        }
        
        // If no flags are set, use -i (prevent idle sleep) as a default
        if arguments.isEmpty {
            arguments.append("-i")
        }
        
        // Add time limit if not indefinite
        if minutes > 0 {
            arguments.append("-t")
            arguments.append("\(minutes * 60)") // Convert minutes to seconds
        }
        
        task.arguments = arguments
        
        do {
            try task.run()
            cafeinateProcess = task
            isActive = true
            currentDuration = minutes
            
            // Update the menu bar icon
            if let appDelegate = NSApp.delegate as? AppDelegate {
                appDelegate.updateMenuBarIcon(isActive: true)
            }
            
            // Set up timer for countdown if not indefinite
            if minutes > 0 {
                remainingTime = minutes * 60
                endTime = Date().addingTimeInterval(TimeInterval(remainingTime))
                
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                    guard let self = self else { return }
                    
                    if self.remainingTime > 0 {
                        self.remainingTime -= 1
                    } else {
                        self.deactivate()
                    }
                }
            }
        } catch {
            print("Failed to start caffeinate: \(error.localizedDescription)")
        }
    }
    
    func deactivate() {
        // Stop the caffeinate process
        if let process = cafeinateProcess, process.isRunning {
            process.terminate()
            cafeinateProcess = nil
        }
        
        // Stop the timer
        timer?.invalidate()
        timer = nil
        
        // Reset state
        isActive = false
        currentDuration = 0
        remainingTime = 0
        endTime = nil
        
        // Update the menu bar icon
        if let appDelegate = NSApp.delegate as? AppDelegate {
            appDelegate.updateMenuBarIcon(isActive: false)
        }
    }
    
    func formattedRemainingTime() -> String {
        if currentDuration == 0 {
            return "Indefinite"
        }
        
        let hours = remainingTime / 3600
        let minutes = (remainingTime % 3600) / 60
        let seconds = remainingTime % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
