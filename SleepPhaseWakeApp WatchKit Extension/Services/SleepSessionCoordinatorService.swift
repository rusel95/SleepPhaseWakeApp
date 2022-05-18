//
//  SleepSessionCoordinatorService.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 18.05.2022.
//

import SwiftUI
import CoreMotion

final class SleepSessionCoordinatorService: NSObject {

    // MARK: - PROPERTY
    
    private var runtimeSession: WKExtendedRuntimeSession?
    private let sensorRecorder = CMSensorRecorder()

    @AppStorage("lastSessionStart") private var lastSessionStart: Date?

    private let defaultDurationTimeInterval = TimeInterval(2*60) // 2 minutes

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

        scheduleDataProcessing()
    }

    func invalidate() {
        logAccelerometerData()
        lastSessionStart = nil

        runtimeSession?.notifyUser(hapticType: .click)
        runtimeSession?.delegate = nil
        runtimeSession?.invalidate()
    }

}

// MARK: - WKExtendedRuntimeSessionDelegate

extension SleepSessionCoordinatorService: WKExtendedRuntimeSessionDelegate {

    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession,
                                didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
                                error: Error?) {
        print("Session stopped at", Date())
        debugPrint(extendedRuntimeSession, reason, error)
    }

    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Session stopped at", Date())
        debugPrint(extendedRuntimeSession)
    }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {

    }

}

// MARK: - Helpers

private extension SleepSessionCoordinatorService {

    func scheduleDataProcessing() {
        // NOTE: - Simulate Smart Alarm - show some notification after 1.5 minutes
        DispatchQueue.main.asyncAfter(deadline: .now() + defaultDurationTimeInterval - 30) {
            self.runtimeSession?.notifyUser(hapticType: .start)
        }
    }

    func logAccelerometerData() {
        guard let lastSessionStart = lastSessionStart,  lastSessionStart.timeIntervalSinceNow > 0,
            let list = sensorRecorder.accelerometerData(from: lastSessionStart, to: Date())?.enumerated() else { return }

        for item in list {
            guard let data = item.element as? CMRecordedAccelerometerData else { return }

            let totalAcceleration = sqrt(data.acceleration.x * data.acceleration.x + data.acceleration.y * data.acceleration.y + data.acceleration.z * data.acceleration.z)
            print(data.startDate, data.acceleration.x, data.acceleration.y, data.acceleration.z, totalAcceleration)
        }
    }

}
