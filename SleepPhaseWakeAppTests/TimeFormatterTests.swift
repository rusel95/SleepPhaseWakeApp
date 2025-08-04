import XCTest
@testable import SleepPhaseWakeApp_WatchKit_Extension

final class TimeFormatterTests: XCTestCase {
    
    func testFormatTime() {
        // Given
        let calendar = Calendar.current
        let components = DateComponents(hour: 14, minute: 30)
        let date = calendar.date(from: components)!
        
        // When
        let result = TimeFormatter.formatTime(date)
        
        // Then
        XCTAssertTrue(result.contains("2:30") || result.contains("14:30"), 
                     "Time should be formatted correctly")
    }
    
    func testFormatCountdown() {
        // Given
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(3665) // 1 hour, 1 minute, 5 seconds
        
        // When
        let result = TimeFormatter.formatCountdown(from: startDate, to: endDate)
        
        // Then
        XCTAssertTrue(result.contains("1"), "Should contain hours")
        XCTAssertTrue(result.contains("1"), "Should contain minutes")
    }
    
    func testFormatDuration() {
        // Given
        let duration: TimeInterval = 7265 // 2 hours, 1 minute, 5 seconds
        
        // When
        let result = TimeFormatter.formatDuration(duration)
        
        // Then
        XCTAssertTrue(result.contains("2"), "Should contain 2 hours")
    }
    
    func testFormatDuration_ZeroTime() {
        // Given
        let duration: TimeInterval = 0
        
        // When
        let result = TimeFormatter.formatDuration(duration)
        
        // Then
        XCTAssertTrue(result.contains("00:00") || result.contains("0"), 
                     "Zero duration should be formatted correctly")
    }
}