import Foundation
import SwiftUI

struct ScheduleDay: Identifiable, Codable {
    var id = UUID()
    var dayOfWeek: Int // 0 = Sunday, 1 = Monday, etc.
    var isEnabled: Bool
    var startTime: Date
    var endTime: Date
    
    var isActive: Bool {
        guard isEnabled else { return false }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Check if today is the scheduled day
        let today = calendar.component(.weekday, from: now) - 1 // Convert to 0-based index
        if today != dayOfWeek { return false }
        
        // Extract hours and minutes from the current time
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentSeconds = currentHour * 3600 + currentMinute * 60
        
        // Extract hours and minutes from the start time
        let startHour = calendar.component(.hour, from: startTime)
        let startMinute = calendar.component(.minute, from: startTime)
        let startSeconds = startHour * 3600 + startMinute * 60
        
        // Extract hours and minutes from the end time
        let endHour = calendar.component(.hour, from: endTime)
        let endMinute = calendar.component(.minute, from: endTime)
        let endSeconds = endHour * 3600 + endMinute * 60
        
        // Check if current time is within the scheduled time range
        return currentSeconds >= startSeconds && currentSeconds <= endSeconds
    }
}

class ScheduleManager: ObservableObject {
    @Published var scheduleDays: [ScheduleDay] {
        didSet {
            saveSchedule()
        }
    }
    
    @Published var isScheduleEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isScheduleEnabled, forKey: "isScheduleEnabled")
            checkScheduleStatus()
        }
    }
    
    private var timer: Timer?
    private var cafeinateManager: CafeinateManager
    
    init(cafeinateManager: CafeinateManager) {
        self.cafeinateManager = cafeinateManager
        
        // Initialize properties first
        self.scheduleDays = []
        self.isScheduleEnabled = UserDefaults.standard.bool(forKey: "isScheduleEnabled")
        
        // Helper function to create time without using self
        func makeTime(hour: Int, minute: Int) -> Date {
            var components = DateComponents()
            components.hour = hour
            components.minute = minute
            return Calendar.current.date(from: components) ?? Date()
        }
        
        // Create default schedule (Mon-Fri, 9am-5pm)
        let defaultSchedule = [
            ScheduleDay(dayOfWeek: 1, isEnabled: true, startTime: makeTime(hour: 9, minute: 0), endTime: makeTime(hour: 17, minute: 0)),
            ScheduleDay(dayOfWeek: 2, isEnabled: true, startTime: makeTime(hour: 9, minute: 0), endTime: makeTime(hour: 17, minute: 0)),
            ScheduleDay(dayOfWeek: 3, isEnabled: true, startTime: makeTime(hour: 9, minute: 0), endTime: makeTime(hour: 17, minute: 0)),
            ScheduleDay(dayOfWeek: 4, isEnabled: true, startTime: makeTime(hour: 9, minute: 0), endTime: makeTime(hour: 17, minute: 0)),
            ScheduleDay(dayOfWeek: 5, isEnabled: true, startTime: makeTime(hour: 9, minute: 0), endTime: makeTime(hour: 17, minute: 0)),
            ScheduleDay(dayOfWeek: 6, isEnabled: false, startTime: makeTime(hour: 9, minute: 0), endTime: makeTime(hour: 17, minute: 0)),
            ScheduleDay(dayOfWeek: 0, isEnabled: false, startTime: makeTime(hour: 9, minute: 0), endTime: makeTime(hour: 17, minute: 0))
        ]
        
        // Load saved schedule or use default
        if let savedSchedule = loadSchedule() {
            self.scheduleDays = savedSchedule
        } else {
            self.scheduleDays = defaultSchedule
        }
        
        // Start the timer to check schedule status
        startTimer()
    }
    
    private func createTime(hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        return calendar.date(from: components) ?? Date()
    }
    
    private func startTimer() {
        // Check every minute
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.checkScheduleStatus()
        }
        
        // Also check immediately
        checkScheduleStatus()
    }
    
    func checkScheduleStatus() {
        guard isScheduleEnabled else { return }
        
        // Check if any schedule is active
        let isAnyScheduleActive = scheduleDays.contains { $0.isActive }
        
        if isAnyScheduleActive && !cafeinateManager.isActive {
            // Activate if schedule is active and caffeinate is not
            cafeinateManager.activate(minutes: 0) // Indefinite until schedule ends
        } else if !isAnyScheduleActive && cafeinateManager.isActive {
            // Only deactivate if caffeinate was activated by the schedule
            // This allows manual activation to override the schedule
            if cafeinateManager.activatedBySchedule {
                cafeinateManager.deactivate()
            }
        }
    }
    
    func getNextScheduledTime() -> String {
        guard isScheduleEnabled else { return "No schedule" }
        
        let calendar = Calendar.current
        let now = Date()
        let currentDayOfWeek = calendar.component(.weekday, from: now) - 1 // Convert to 0-based
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentSeconds = currentHour * 3600 + currentMinute * 60
        
        // Check today's schedule first
        if let todaySchedule = scheduleDays.first(where: { $0.dayOfWeek == currentDayOfWeek && $0.isEnabled }) {
            let startHour = calendar.component(.hour, from: todaySchedule.startTime)
            let startMinute = calendar.component(.minute, from: todaySchedule.startTime)
            let startSeconds = startHour * 3600 + startMinute * 60
            
            if currentSeconds < startSeconds {
                // Today's schedule hasn't started yet
                return "Today at \(formatTime(todaySchedule.startTime))"
            }
        }
        
        // Check upcoming days
        for daysAhead in 1...7 {
            let nextDay = (currentDayOfWeek + daysAhead) % 7
            if let nextSchedule = scheduleDays.first(where: { $0.dayOfWeek == nextDay && $0.isEnabled }) {
                let dayName = getDayName(nextDay)
                return "\(dayName) at \(formatTime(nextSchedule.startTime))"
            }
        }
        
        return "No upcoming schedule"
    }
    
    private func getDayName(_ dayOfWeek: Int) -> String {
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        return days[dayOfWeek]
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func saveSchedule() {
        if let encoded = try? JSONEncoder().encode(scheduleDays) {
            UserDefaults.standard.set(encoded, forKey: "scheduleDays")
        }
    }
    
    private func loadSchedule() -> [ScheduleDay]? {
        if let savedSchedule = UserDefaults.standard.data(forKey: "scheduleDays"),
           let decodedSchedule = try? JSONDecoder().decode([ScheduleDay].self, from: savedSchedule) {
            return decodedSchedule
        }
        return nil
    }
}
