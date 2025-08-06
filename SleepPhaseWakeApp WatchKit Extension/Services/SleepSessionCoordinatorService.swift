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

final class SleepSessionCoordinatorService: NSObject, SessionCoordinating {

    // MARK: - PROPERTY

    static let shared: SleepSessionCoordinatorService = SleepSessionCoordinatorService()
    
    @AppStorage("lastSessionStart") private var lastSessionStart: Date?

    private let stateManager = AppStateManager.shared
    private let accelerometerService = AccelerometerService.shared
    private let notificationService = UserNotificationService.shared
    private let runtimeSessionManager = RuntimeSessionManager()
    private let movementMonitor = MovementMonitor()

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
        guard !runtimeSessionManager.isRunning else { return }

        logger.info("Sleep Session started")

        if stateManager.isSimulationMode {
            HapticFeedback.impact(.start)
        }

        // NOTE: Should start 30 minutes before wake time
        let processingSessionStartDate = stateManager.isSimulationMode
            ? Date().addingTimeInterval(AppConfiguration.SleepTracking.simulationWakeWindowDuration / 2.0)
        : stateManager.wakeUpDate.addingTimeInterval(-AppConfiguration.SleepTracking.defaultWakeWindowDuration)
        
        runtimeSessionManager.start(at: processingSessionStartDate, delegate: self)
        lastSessionStart = Date()
        
        // Start accelerometer recording
        accelerometerService.startRecording()
    }

    func invalidate() {
        logger.info("Sleep Session Stopped")
        movementMonitor.stopMonitoring()
        runtimeSessionManager.stop()
        lastSessionStart = nil
        stateManager.measureState = .notStarted
        
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
        if stateManager.isSimulationMode {
            HapticFeedback.impact(.stop)
        }
    }

    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        logger.info("Session Started")
        if stateManager.isSimulationMode {
            HapticFeedback.selection()
        }
        
        movementMonitor.startMonitoring { [weak self] in
            self?.handleWakeUpDetected()
        }
    }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        logger.error("Session will expire")
        if stateManager.isSimulationMode {
            HapticFeedback.error()
        }
    }

}

// MARK: - HELPERS

private extension SleepSessionCoordinatorService {
    
    func handleWakeUpDetected() {
        logger.info("Movement detected - triggering wake up")
        
        // Notify user with system alarm
        runtimeSessionManager.notifyUser(hapticType: .notification)
        
        // Schedule a user notification as backup
        notificationService.scheduleWakeUpNotification(
            title: "Good Morning!",
            body: "Time to wake up",
            sound: UNNotificationSound.default
        )
        
        // Update app state
        stateManager.measureState = .finished
    }
}
