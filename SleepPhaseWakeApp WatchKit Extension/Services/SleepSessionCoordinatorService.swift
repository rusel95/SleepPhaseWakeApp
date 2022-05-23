//
//  SleepSessionCoordinatorService.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 18.05.2022.
//

import SwiftUI
import CoreMotion
import OSLog

final class SleepSessionCoordinatorService: NSObject {

    // MARK: - PROPERTY

    static let shared: SleepSessionCoordinatorService = SleepSessionCoordinatorService()
    
    private var runtimeSession: WKExtendedRuntimeSession?
    private let sensorRecorder = CMSensorRecorder()

    @AppStorage("lastSessionStart") private var lastSessionStart: Date?

    private let defaultDurationTimeInterval = TimeInterval(2*60) // 2 minutes
    private let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? "ruslanpopesku", category: "SleepSessionCoordinatorService")

    // MARK: - INIT

    private override init() { }

    deinit {
        print("OOps")
    }

    // MARK: - METHODS

    func start() {
        guard runtimeSession?.state != .running else { return }

        // create or recreate session if needed
        if runtimeSession == nil || runtimeSession?.state == .invalid {
            runtimeSession = WKExtendedRuntimeSession()
        }
        runtimeSession?.delegate = self
        runtimeSession?.start(at: Date().addingTimeInterval(defaultDurationTimeInterval))

        lastSessionStart = Date()

        if CMSensorRecorder.isAccelerometerRecordingAvailable() {
            DispatchQueue.global(qos: .background).async {
                self.sensorRecorder.recordAccelerometer(forDuration: self.defaultDurationTimeInterval)
            }
        }
    }

    func invalidate() {
        logAccelerometerData()
        lastSessionStart = nil

        runtimeSession?.delegate = nil
        runtimeSession?.invalidate()
    }

}

// MARK: - WKExtendedRuntimeSessionDelegate

extension SleepSessionCoordinatorService: WKExtendedRuntimeSessionDelegate {

    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession,
                                didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
                                error: Error?) {
        log.info("Session invalidated with reason: \(reason.rawValue), error: \(error.debugDescription)")
    }

    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        log.info("Session started")
        scheduleDataProcessing()
    }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        log.error("Session will expire")
    }

}

// MARK: - Helpers

private extension SleepSessionCoordinatorService {

    func scheduleDataProcessing() {
        // NOTE: - Simulate Smart Alarm - show some notification after 1.5 minutes
        DispatchQueue.main.asyncAfter(deadline: .now() + defaultDurationTimeInterval - 30) {
            self.log.info("Data Processing started")
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                let device = WKInterfaceDevice.current()
                device.play(.start)
            })
            if self.runtimeSession?.state == .running {
                self.runtimeSession?.notifyUser(hapticType: .start)
            }
        }
    }

    func logAccelerometerData() {
        log.info("Accelerometer Data Logging Started")
        guard let lastSessionStart = lastSessionStart,  lastSessionStart.timeIntervalSinceNow > 0,
            let list = sensorRecorder.accelerometerData(from: lastSessionStart, to: Date())?.enumerated() else { return }

        for item in list {
            guard let data = item.element as? CMRecordedAccelerometerData else { return }

            let totalAcceleration = sqrt(data.acceleration.x * data.acceleration.x + data.acceleration.y * data.acceleration.y + data.acceleration.z * data.acceleration.z)
            let accelerationExplanation = "\(data.startDate) \(data.acceleration.x) \(data.acceleration.y) \(data.acceleration.z) \(totalAcceleration)"
            log.debug("\(accelerationExplanation)")
        }
    }

}
