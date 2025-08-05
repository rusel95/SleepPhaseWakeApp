//
//  SleepSessionCoordinatorService.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 18.05.2022.
//

import SwiftUI
import CoreMotion
import OSLog
import HealthKit
import UserNotifications

final class SleepSessionCoordinatorService: NSObject {

    // MARK: - PROPERTY

    static let shared: SleepSessionCoordinatorService = SleepSessionCoordinatorService()
    
    private var runtimeSession: WKExtendedRuntimeSession?
    private var processingTimer: Timer?

    @AppStorage("measureState") private var state: String = MeasureState.started.rawValue
    @AppStorage("lastSessionStart") private var lastSessionStart: Date?
    @AppStorage("wakeUpDate") private var wakeUpDate: Date = Date() // default value should never be used
    @AppStorage("isSimulationMode") private var isSimulationMode: Bool = false

    private let accelerometerService = AccelerometerService.shared
    private let movementDetector = MovementDetector()
    private let notificationService = UserNotificationService.shared

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "SleepSessionCoordinatorService")

    // MARK: - INIT

    override private init() {
        super.init()
    }

    deinit {
        logger.error("SleepSessionCoordinatorService deinited")
    }

    // MARK: - METHODS

    func start() {
        guard runtimeSession?.state != .running else { return }

        logger.info("Sleep Session started")

        if isSimulationMode {
            WKInterfaceDevice.current().play(.start)
        }

        // NOTE: Create or recreate session if needed
        if runtimeSession == nil || runtimeSession?.state == .invalid {
            runtimeSession = WKExtendedRuntimeSession()
        }
        runtimeSession?.delegate = self

        // NOTE: Should start 30 minutes before wake time
        let processingSessionStartDate = isSimulationMode
            ? Date().addingTimeInterval(AppConfiguration.SleepTracking.simulationWakeWindowDuration / 2.0)
        : wakeUpDate.addingTimeInterval(-AppConfiguration.SleepTracking.defaultWakeWindowDuration)
        runtimeSession?.start(at: processingSessionStartDate)

        lastSessionStart = Date()
        
        // Start accelerometer recording
        accelerometerService.startRecording()
    }

    func invalidate() {
        logger.info("Sleep Session Stopped")
        processingTimer?.invalidate()
        runtimeSession?.delegate = nil
        runtimeSession?.invalidate()
        lastSessionStart = nil
        state = MeasureState.notStarted.rawValue
        
        // Stop accelerometer recording
        accelerometerService.stopRecording()
    }

}

// MARK: - WKExtendedRuntimeSessionDelegate

extension SleepSessionCoordinatorService: WKExtendedRuntimeSessionDelegate {

    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession,
                                didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
                                error: Error?) {
        logger.info("Session invalidated with reason: \(reason.rawValue), error: \(error.debugDescription)")
        if isSimulationMode {
            WKInterfaceDevice.current().play(.stop)
        }
    }

    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        logger.info("Session Started")
        if isSimulationMode {
            WKInterfaceDevice.current().play(.click)
        }
        scheduleDataProcessing()
    }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        logger.error("Session will expire")
        if isSimulationMode {
            WKInterfaceDevice.current().play(.failure)
        }
    }

}

// MARK: - HELPERS

private extension SleepSessionCoordinatorService {

    func scheduleDataProcessing() {
        logger.info("Data Processing started")
        processingTimer = Timer.scheduledTimer(withTimeInterval: AppConfiguration.SleepTracking.dataProcessingInterval, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            // Play click sound in simulation mode
            if self.isSimulationMode {
                WKInterfaceDevice.current().play(.click)
            }
            
            self.checkForMovement(timer: timer)
        }
        
        if let logTimer = processingTimer {
            RunLoop.current.add(logTimer, forMode: .common)
        }
    }
    
    private func checkForMovement(timer: Timer) {
        guard runtimeSession?.state == .running else { return }
        
        let queryStartDate = Date().addingTimeInterval(-AppConfiguration.SleepTracking.accelerometerLookbackTime)
        let queryEndDate = Date()
        
        accelerometerService.queryRecordedData(from: queryStartDate, to: queryEndDate) { [weak self] dataList in
            guard let self = self,
                  let dataList = dataList else { return }
            
            // Process accelerometer data
            for dataList in dataList {
                for data in dataList {
                    if let accelerometerData = data as? CMRecordedAccelerometerData {
                        if self.movementDetector.handleAccelerometerData(accelerometerData) {
                            self.handleWakeUpDetected(timer: timer)
                            return
                        }
                    }
                }
            }
        }
    }
    
    private func handleWakeUpDetected(timer: Timer) {
        logger.info("Movement detected - triggering wake up")
        
        if isSimulationMode {
            WKInterfaceDevice.current().play(.stop)
        }
        
        timer.invalidate()
        
        // Notify user with system alarm
        runtimeSession?.notifyUser(hapticType: .stop)
        
        // Schedule a user notification as backup
        notificationService.scheduleWakeUpNotification(
            title: "Good Morning!",
            body: "Time to wake up",
            sound: UNNotificationSound.default
        )
        
        // Update app state
        state = MeasureState.finished.rawValue
    }

}
