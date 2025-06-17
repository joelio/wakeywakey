import XCTest
@testable import WakeyWakey

final class ScheduleManagerTests: XCTestCase {
    var cafeinateManager: CafeinateManager!
    var scheduleManager: ScheduleManager!
    
    override func setUp() {
        super.setUp()
        cafeinateManager = CafeinateManager()
        scheduleManager = ScheduleManager(cafeinateManager: cafeinateManager)
    }
    
    override func tearDown() {
        cafeinateManager.deactivate()
        cafeinateManager = nil
        scheduleManager = nil
        super.tearDown()
    }
    
    func testInitialState() {
        // Verify default schedule (Mon-Fri, 9am-5pm)
        XCTAssertEqual(scheduleManager.scheduleDays.count, 7, "Should have 7 days in the schedule")
        
        // Check weekday settings (Monday to Friday)
        for dayIndex in 1...5 {
            let day = scheduleManager.scheduleDays.first { $0.dayOfWeek == dayIndex }
            XCTAssertNotNil(day, "Day \(dayIndex) should exist in schedule")
            XCTAssertTrue(day?.isEnabled ?? false, "Weekday \(dayIndex) should be enabled by default")
        }
        
        // Check weekend settings (Saturday and Sunday)
        let saturday = scheduleManager.scheduleDays.first { $0.dayOfWeek == 6 }
        let sunday = scheduleManager.scheduleDays.first { $0.dayOfWeek == 0 }
        XCTAssertNotNil(saturday, "Saturday should exist in schedule")
        XCTAssertNotNil(sunday, "Sunday should exist in schedule")
        XCTAssertFalse(saturday?.isEnabled ?? true, "Saturday should be disabled by default")
        XCTAssertFalse(sunday?.isEnabled ?? true, "Sunday should be disabled by default")
    }
    
    func testScheduleEnabledState() {
        // Test toggling schedule enabled state
        scheduleManager.isScheduleEnabled = true
        XCTAssertTrue(scheduleManager.isScheduleEnabled, "Schedule should be enabled")
        
        scheduleManager.isScheduleEnabled = false
        XCTAssertFalse(scheduleManager.isScheduleEnabled, "Schedule should be disabled")
    }
    
    func testGetNextScheduledTime() {
        // When schedule is disabled
        scheduleManager.isScheduleEnabled = false
        XCTAssertEqual(scheduleManager.getNextScheduledTime(), "No schedule", "Should show 'No schedule' when disabled")
        
        // Enable schedule for testing next scheduled time
        scheduleManager.isScheduleEnabled = true
        
        // Create a test schedule with only one day enabled
        let calendar = Calendar.current
        let now = Date()
        let currentDayOfWeek = calendar.component(.weekday, from: now) - 1 // Convert to 0-based
        let nextDayOfWeek = (currentDayOfWeek + 1) % 7
        
        // Disable all days
        for i in 0..<scheduleManager.scheduleDays.count {
            scheduleManager.scheduleDays[i].isEnabled = false
        }
        
        // Enable only the next day
        if let index = scheduleManager.scheduleDays.firstIndex(where: { $0.dayOfWeek == nextDayOfWeek }) {
            scheduleManager.scheduleDays[index].isEnabled = true
            
            // Set start time to 9:00 AM
            let startTime = createTime(hour: 9, minute: 0)
            scheduleManager.scheduleDays[index].startTime = startTime
            
            // Expected day name
            let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
            let expectedDayName = dayNames[nextDayOfWeek]
            
            // Format expected time
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            let expectedTime = formatter.string(from: startTime)
            
            // Check next scheduled time
            let nextScheduled = scheduleManager.getNextScheduledTime()
            XCTAssertEqual(nextScheduled, "\(expectedDayName) at \(expectedTime)", "Next scheduled time should show correct day and time")
        }
    }
    
    func testScheduleDayActiveState() {
        // Create a test day for today
        let calendar = Calendar.current
        let now = Date()
        let currentDayOfWeek = calendar.component(.weekday, from: now) - 1 // Convert to 0-based
        
        // Create a schedule day that should be active now
        let currentHour = calendar.component(.hour, from: now)
        let startHour = max(0, currentHour - 1) // 1 hour before current time
        let endHour = min(23, currentHour + 1) // 1 hour after current time
        
        let testDay = ScheduleDay(
            dayOfWeek: currentDayOfWeek,
            isEnabled: true,
            startTime: createTime(hour: startHour, minute: 0),
            endTime: createTime(hour: endHour, minute: 0)
        )
        
        XCTAssertTrue(testDay.isActive, "Schedule day should be active when current time is within range")
        
        // Create a schedule day that should not be active now
        let inactiveDay = ScheduleDay(
            dayOfWeek: currentDayOfWeek,
            isEnabled: true,
            startTime: createTime(hour: (currentHour + 2) % 24, minute: 0),
            endTime: createTime(hour: (currentHour + 3) % 24, minute: 0)
        )
        
        XCTAssertFalse(inactiveDay.isActive, "Schedule day should not be active when current time is outside range")
        
        // Test disabled day
        let disabledDay = ScheduleDay(
            dayOfWeek: currentDayOfWeek,
            isEnabled: false,
            startTime: createTime(hour: startHour, minute: 0),
            endTime: createTime(hour: endHour, minute: 0)
        )
        
        XCTAssertFalse(disabledDay.isActive, "Disabled schedule day should not be active even if time is within range")
    }
    
    // Helper function to create a Date with specific hour and minute
    private func createTime(hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        return calendar.date(from: components) ?? Date()
    }
}
