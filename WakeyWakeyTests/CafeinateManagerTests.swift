import XCTest
@testable import WakeyWakey

final class CafeinateManagerTests: XCTestCase {
    var cafeinateManager: CafeinateManager!
    
    override func setUp() {
        super.setUp()
        cafeinateManager = CafeinateManager()
    }
    
    override func tearDown() {
        cafeinateManager.deactivate()
        cafeinateManager = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertFalse(cafeinateManager.isActive, "CafeinateManager should not be active initially")
        XCTAssertEqual(cafeinateManager.currentDuration, 0, "Initial duration should be 0")
        XCTAssertEqual(cafeinateManager.remainingTime, 0, "Initial remaining time should be 0")
        XCTAssertNil(cafeinateManager.endTime, "End time should be nil initially")
        XCTAssertEqual(cafeinateManager.activationSource, .manual, "Initial activation source should be manual")
    }
    
    func testActivateIndefinite() {
        cafeinateManager.activate(minutes: 0)
        
        XCTAssertTrue(cafeinateManager.isActive, "CafeinateManager should be active after activation")
        XCTAssertEqual(cafeinateManager.currentDuration, 0, "Duration should be 0 for indefinite activation")
        XCTAssertEqual(cafeinateManager.remainingTime, 0, "Remaining time should be 0 for indefinite activation")
        XCTAssertNil(cafeinateManager.endTime, "End time should be nil for indefinite activation")
        XCTAssertEqual(cafeinateManager.activationSource, .manual, "Activation source should be manual")
    }
    
    func testActivateWithDuration() {
        cafeinateManager.activate(minutes: 30)
        
        XCTAssertTrue(cafeinateManager.isActive, "CafeinateManager should be active after activation")
        XCTAssertEqual(cafeinateManager.currentDuration, 30, "Duration should be set correctly")
        XCTAssertEqual(cafeinateManager.remainingTime, 30 * 60, "Remaining time should be set in seconds")
        XCTAssertNotNil(cafeinateManager.endTime, "End time should be set for timed activation")
        XCTAssertEqual(cafeinateManager.activationSource, .manual, "Activation source should be manual")
    }
    
    func testDeactivate() {
        cafeinateManager.activate(minutes: 30)
        cafeinateManager.deactivate()
        
        XCTAssertFalse(cafeinateManager.isActive, "CafeinateManager should not be active after deactivation")
        XCTAssertEqual(cafeinateManager.currentDuration, 0, "Duration should be reset to 0")
        XCTAssertEqual(cafeinateManager.remainingTime, 0, "Remaining time should be reset to 0")
        XCTAssertNil(cafeinateManager.endTime, "End time should be nil after deactivation")
        XCTAssertEqual(cafeinateManager.activationSource, .manual, "Activation source should be reset to manual")
    }
    
    func testActivationSource() {
        cafeinateManager.activate(minutes: 30, source: .schedule)
        XCTAssertEqual(cafeinateManager.activationSource, .schedule, "Activation source should be schedule")
        XCTAssertTrue(cafeinateManager.activatedBySchedule, "activatedBySchedule should be true")
        XCTAssertFalse(cafeinateManager.activatedByApp, "activatedByApp should be false")
        
        cafeinateManager.deactivate()
        cafeinateManager.activate(minutes: 30, source: .app)
        XCTAssertEqual(cafeinateManager.activationSource, .app, "Activation source should be app")
        XCTAssertFalse(cafeinateManager.activatedBySchedule, "activatedBySchedule should be false")
        XCTAssertTrue(cafeinateManager.activatedByApp, "activatedByApp should be true")
    }
    
    func testFormattedRemainingTime() {
        cafeinateManager.activate(minutes: 0)
        XCTAssertEqual(cafeinateManager.formattedRemainingTime(), "Indefinite", "Indefinite time should be formatted correctly")
        
        cafeinateManager.deactivate()
        cafeinateManager.activate(minutes: 30)
        cafeinateManager.remainingTime = 30 * 60 // 30 minutes
        XCTAssertEqual(cafeinateManager.formattedRemainingTime(), "30:00", "30 minutes should be formatted correctly")
        
        cafeinateManager.deactivate()
        cafeinateManager.activate(minutes: 90)
        cafeinateManager.remainingTime = 90 * 60 // 1 hour 30 minutes
        XCTAssertEqual(cafeinateManager.formattedRemainingTime(), "1:30:00", "1 hour 30 minutes should be formatted correctly")
    }
}
