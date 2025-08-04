import XCTest
@testable import SleepPhaseWakeApp_WatchKit_Extension

final class AppStateManagerTests: XCTestCase {
    
    var sut: AppStateManager!
    
    override func setUp() {
        super.setUp()
        sut = AppStateManager()
    }
    
    override func tearDown() {
        sut.reset()
        sut = nil
        super.tearDown()
    }
    
    func testInitialState() {
        // Then
        XCTAssertEqual(sut.measureState, .notStarted)
        XCTAssertFalse(sut.isSimulationMode)
        XCTAssertNil(sut.startedDate)
        XCTAssertNil(sut.stoppedDate)
    }
    
    func testMeasureStateTransitions() {
        // When & Then
        sut.measureState = .started
        XCTAssertEqual(sut.measureState, .started)
        
        sut.measureState = .finished
        XCTAssertEqual(sut.measureState, .finished)
        
        sut.measureState = .notStarted
        XCTAssertEqual(sut.measureState, .notStarted)
    }
    
    func testReset() {
        // Given
        sut.measureState = .started
        sut.startedDate = Date()
        sut.stoppedDate = Date()
        
        // When
        sut.reset()
        
        // Then
        XCTAssertEqual(sut.measureState, .notStarted)
        XCTAssertNil(sut.startedDate)
        XCTAssertNil(sut.stoppedDate)
    }
    
    func testSimulationModeToggle() {
        // Given
        let initialMode = sut.isSimulationMode
        
        // When
        sut.isSimulationMode.toggle()
        
        // Then
        XCTAssertNotEqual(sut.isSimulationMode, initialMode)
    }
    
    func testWakeUpDateUpdate() {
        // Given
        let newWakeUpDate = Date().addingTimeInterval(3600) // 1 hour from now
        
        // When
        sut.wakeUpDate = newWakeUpDate
        
        // Then
        XCTAssertEqual(sut.wakeUpDate, newWakeUpDate)
    }
}