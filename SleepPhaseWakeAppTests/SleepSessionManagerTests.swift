import XCTest
@testable import SleepPhaseWakeApp_WatchKit_Extension

final class SleepSessionManagerTests: XCTestCase {
    
    var sut: SleepSessionManager!
    var mockStateManager: MockStateManager!
    var mockSensorProvider: MockSensorDataProvider!
    var mockMovementDetector: MockMovementDetector!
    var mockNotificationService: MockNotificationService!
    
    override func setUp() {
        super.setUp()
        mockStateManager = MockStateManager()
        mockSensorProvider = MockSensorDataProvider()
        mockMovementDetector = MockMovementDetector()
        mockNotificationService = MockNotificationService()
        
        sut = SleepSessionManager(
            stateManager: mockStateManager,
            sensorDataProvider: mockSensorProvider,
            movementDetector: mockMovementDetector,
            notificationService: mockNotificationService
        )
    }
    
    override func tearDown() {
        sut = nil
        mockStateManager = nil
        mockSensorProvider = nil
        mockMovementDetector = nil
        mockNotificationService = nil
        super.tearDown()
    }
    
    func testStartSession_WithNotificationPermission_StartsSuccessfully() {
        // Given
        let expectation = expectation(description: "Session start completion")
        mockNotificationService.shouldGrantPermission = true
        let wakeUpDate = Date().addingTimeInterval(3600)
        
        // When
        sut.startSession(wakeUpDate: wakeUpDate) { success in
            // Then
            XCTAssertTrue(success)
            XCTAssertEqual(self.mockStateManager.measureState, .started)
            XCTAssertEqual(self.mockStateManager.wakeUpDate, wakeUpDate)
            XCTAssertNotNil(self.mockStateManager.startedDate)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testStartSession_WithoutNotificationPermission_FailsToStart() {
        // Given
        let expectation = expectation(description: "Session start completion")
        mockNotificationService.shouldGrantPermission = false
        let wakeUpDate = Date().addingTimeInterval(3600)
        
        // When
        sut.startSession(wakeUpDate: wakeUpDate) { success in
            // Then
            XCTAssertFalse(success)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testStopSession_UpdatesStateCorrectly() {
        // Given
        mockStateManager.measureState = .started
        
        // When
        sut.stopSession()
        
        // Then
        XCTAssertEqual(mockStateManager.measureState, .finished)
        XCTAssertNotNil(mockStateManager.stoppedDate)
        XCTAssertTrue(mockSensorProvider.stopRecordingCalled)
        XCTAssertTrue(mockNotificationService.scheduleWakeUpNotificationCalled)
    }
    
    func testSimulationMode_SchedulesShortTimer() {
        // Given
        let expectation = expectation(description: "Session start completion")
        mockNotificationService.shouldGrantPermission = true
        mockStateManager.isSimulationMode = true
        let wakeUpDate = Date().addingTimeInterval(3600)
        
        // When
        sut.startSession(wakeUpDate: wakeUpDate) { success in
            // Then
            XCTAssertTrue(success)
            XCTAssertEqual(self.mockStateManager.measureState, .started)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
}

// MARK: - Mock Classes

class MockStateManager: AppStateManager {
    override init() {
        super.init()
    }
}

class MockSensorDataProvider: SensorDataProvider {
    var startRecordingCalled = false
    var stopRecordingCalled = false
    var mockData: [CMSensorDataList]?
    
    func startRecording() {
        startRecordingCalled = true
    }
    
    func stopRecording() {
        stopRecordingCalled = true
    }
    
    func queryRecordedData(from startDate: Date, to endDate: Date, completion: @escaping ([CMSensorDataList]?) -> Void) {
        completion(mockData)
    }
}

class MockMovementDetector: AccelerometerDataHandler {
    var shouldDetectMovement = false
    
    func handleAccelerometerData(_ data: CMAccelerometerData) -> Bool {
        return shouldDetectMovement
    }
}

class MockNotificationService: NotificationService {
    var shouldGrantPermission = true
    var scheduleWakeUpNotificationCalled = false
    var removeAllPendingNotificationsCalled = false
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        completion(shouldGrantPermission)
    }
    
    func scheduleWakeUpNotification(title: String, body: String, sound: UNNotificationSound?) {
        scheduleWakeUpNotificationCalled = true
    }
    
    func removeAllPendingNotifications() {
        removeAllPendingNotificationsCalled = true
    }
}