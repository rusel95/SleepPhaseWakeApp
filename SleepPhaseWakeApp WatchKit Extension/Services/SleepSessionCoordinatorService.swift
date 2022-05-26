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
    private var logTimer: Timer?

    @AppStorage("measureState") private var state: MeasureState = .started
    @AppStorage("lastSessionStart") private var lastSessionStart: Date?

    private let sensorRecorder = CMSensorRecorder()

    private let defaultDurationTimeInterval = TimeInterval(60) // 1 minute
    private let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? "ruslanpopesku", category: "SleepSessionCoordinatorService")


    // MARK: - INIT

    private override init() { }

    deinit {
        log.error("SleepSessionCoordinatorService deinited")
    }

    // MARK: - METHODS

    func start() {
        guard runtimeSession?.state != .running else { return }

        WKInterfaceDevice.current().play(.click)
        //NOTE: Create or recreate session if needed
        if runtimeSession == nil || runtimeSession?.state == .invalid {
            runtimeSession = WKExtendedRuntimeSession()
        }
        runtimeSession?.delegate = self
        // NOTE: Should start 30 minutes before wake time
        runtimeSession?.start(at: Date().addingTimeInterval(1))

        lastSessionStart = Date()

        if CMSensorRecorder.isAccelerometerRecordingAvailable() {
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let self = self else { return }

                self.sensorRecorder.recordAccelerometer(forDuration: self.defaultDurationTimeInterval)
            }
        }
    }

    func invalidate() {
        WKInterfaceDevice.current().play(.success)
        logTimer?.invalidate()
        runtimeSession?.delegate = nil
        runtimeSession?.invalidate()
        lastSessionStart = nil
        state = .noStarted
    }

}

// MARK: - WKExtendedRuntimeSessionDelegate

extension SleepSessionCoordinatorService: WKExtendedRuntimeSessionDelegate {

    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession,
                                didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
                                error: Error?) {
        log.info("Session invalidated with reason: \(reason.rawValue), error: \(error.debugDescription)")
        invalidate()
    }

    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        log.error("Session started")
        WKInterfaceDevice.current().play(.click)
        scheduleDataProcessing()
    }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        log.error("Session will expire")
        WKInterfaceDevice.current().play(.failure)
    }

}

// MARK: - HELPERS

private extension SleepSessionCoordinatorService {

    func scheduleDataProcessing() {
        log.info("Data Processing started")
        logTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            WKInterfaceDevice.current().play(.click)
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let self = self,
                      let list = self.sensorRecorder.accelerometerData(from: Date().addingTimeInterval(TimeInterval(-1)), to: Date())?.enumerated(),
                      self.runtimeSession?.state == .running else { return }

                let accelerometerDataArray = list.compactMap { $0.element as? CMRecordedAccelerometerData }
                let totalAccelerationsArray = accelerometerDataArray.map {
                        sqrt($0.acceleration.x * $0.acceleration.x
                             + $0.acceleration.y * $0.acceleration.y
                             + $0.acceleration.z * $0.acceleration.z)
                    }
                let bigAccelerationsArray = totalAccelerationsArray.filter { $0 > 1.5 }

                // NOTE: - Stop Session if some moving existed
                if bigAccelerationsArray.count > 0 {
                    WKInterfaceDevice.current().play(.stop)
                    // NOTE: - User must be notified that alarm started
                    self.runtimeSession?.notifyUser(hapticType: .stop)
                }
            }
        })
        RunLoop.current.add(logTimer!, forMode: .common)
    }

}
