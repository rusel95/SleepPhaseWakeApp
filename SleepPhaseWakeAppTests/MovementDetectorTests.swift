import XCTest
import CoreMotion
@testable import SleepPhaseWakeApp_WatchKit_Extension

final class MovementDetectorTests: XCTestCase {
    
    var sut: MovementDetector!
    
    override func setUp() {
        super.setUp()
        sut = MovementDetector()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testHandleAccelerometerData_BelowThreshold_ReturnsFalse() {
        // Given
        let mockData = MockAccelerometerData(x: 0.5, y: 0.5, z: 0.5)
        
        // When
        let result = sut.handleAccelerometerData(mockData)
        
        // Then
        XCTAssertFalse(result, "Movement below threshold should return false")
    }
    
    func testHandleAccelerometerData_AboveThreshold_ReturnsTrue() {
        // Given
        let mockData = MockAccelerometerData(x: 1.0, y: 1.0, z: 1.0)
        
        // When
        let result = sut.handleAccelerometerData(mockData)
        
        // Then
        XCTAssertTrue(result, "Movement above threshold should return true")
    }
    
    func testHandleAccelerometerData_ExactlyAtThreshold_ReturnsFalse() {
        // Given
        // Total acceleration = sqrt(0.7^2 + 0.7^2 + 0.7^2) ≈ 1.21
        let mockData = MockAccelerometerData(x: 0.69, y: 0.69, z: 0.69)
        
        // When
        let result = sut.handleAccelerometerData(mockData)
        
        // Then
        XCTAssertFalse(result, "Movement exactly at threshold should return false")
    }
    
    func testCustomThreshold() {
        // Given
        let customThreshold = 2.0
        sut = MovementDetector(movementThreshold: customThreshold)
        let mockData = MockAccelerometerData(x: 1.0, y: 1.0, z: 1.0) // Total ≈ 1.73
        
        // When
        let result = sut.handleAccelerometerData(mockData)
        
        // Then
        XCTAssertFalse(result, "Movement below custom threshold should return false")
    }
}

// MARK: - Mock Classes

class MockAccelerometerData: CMAccelerometerData {
    private let mockAcceleration: CMAcceleration
    
    init(x: Double, y: Double, z: Double) {
        self.mockAcceleration = CMAcceleration(x: x, y: y, z: z)
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var acceleration: CMAcceleration {
        return mockAcceleration
    }
}