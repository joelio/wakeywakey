# Wakey Wakey Test Plan

## Overview
This document outlines the testing strategy for the Wakey Wakey macOS menu bar application. The test plan covers unit testing, UI testing, and integration testing to ensure the application functions correctly and reliably.

## Test Categories

### 1. Unit Tests

#### CafeinateManager Tests
- Test initial state
- Test activation with indefinite duration
- Test activation with specific duration
- Test deactivation
- Test activation source tracking (manual, schedule, app)
- Test remaining time formatting
- Test sleep prevention flags

#### ScheduleManager Tests
- Test initial state and default schedule
- Test schedule enabled/disabled state
- Test next scheduled time calculation
- Test schedule day active state detection
- Test schedule persistence

### 2. UI Tests

#### Menu Bar Icon Tests
- Test icon appearance in active state
- Test icon appearance in inactive state
- Test clicking to show/hide popover

#### Popover UI Tests
- Test duration preset buttons (15m, 30m, 1h, 2h, indefinite)
- Test custom duration input
- Test sleep prevention toggles
- Test launch at startup toggle
- Test about button opens about window
- Test schedule button navigation

#### About Window Tests
- Test window appearance and content
- Test links functionality

#### Schedule View Tests
- Test day toggles
- Test time pickers
- Test schedule enable/disable toggle

### 3. Integration Tests

#### Process Management Tests
- Test caffeinate process is correctly started with appropriate flags
- Test process is terminated on deactivation
- Test process survives app restart when appropriate

#### Schedule Integration Tests
- Test automatic activation based on schedule
- Test schedule override of manual activation
- Test persistence across app restarts

#### System Integration Tests
- Test launch at login functionality
- Test menu bar integration
- Test notifications (if implemented)

## Test Implementation Status

- ✅ CafeinateManager unit tests
- ✅ ScheduleManager unit tests
- ✅ Basic UI test structure (needs system permissions for full testing)
- ⬜ Integration tests

## Testing Challenges

Menu bar applications present unique testing challenges:
1. UI testing requires special permissions to interact with the system menu bar
2. Process management tests need to verify system-level interactions
3. Schedule-based tests may require time manipulation or mocking

## Future Test Improvements

1. Add accessibility identifiers to all UI elements
2. Implement a test mode where the app runs in a window instead of the menu bar
3. Create mock implementations for system services
4. Add time-based test helpers for schedule testing
5. Implement code coverage reporting in CI/CD pipeline
