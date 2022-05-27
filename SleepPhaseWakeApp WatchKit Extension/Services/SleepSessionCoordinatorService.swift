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
        WKInterfaceDevice.current().play(.start)
        log.info("Session invalidated with reason: \(reason.rawValue), error: \(error.debugDescription)")
    }

    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        log.info("Session started")
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

    /* Due to WatchOS system limits max amount of RuntimeSession at Background is 30 minutes
            => We have 30 minutes in summary to Determine the best moment to WakeUp
            => Processing have to be started maximum 30 minutes before Wake UP time
            => User's moves shows Not Deep phase of sleep + We can detect user's moves via Accelerometer
            => Once User moved with hand for the first time while 30 minutes window we have to Wake him Up
     */
    func scheduleDataProcessing() {
        log.info("Data Processing started")

        // NOTE: Current processing starts immediatelly
        logTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            WKInterfaceDevice.current().play(.click)
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let self = self,
                      let list = self.sensorRecorder.accelerometerData(from: Date().addingTimeInterval(TimeInterval(-1)), to: Date())?.enumerated(),
                      self.runtimeSession?.state == .running else { return }

                let accelerometerDataArray = list.compactMap { $0.element as? CMRecordedAccelerometerData }
                let totalAccelerationsArray = accelerometerDataArray.map {
                        sqrt(pow($0.acceleration.x, 2) + pow($0.acceleration.y, 2) + pow($0.acceleration.z, 2))
                    }
                let bigAccelerationsArray = totalAccelerationsArray.filter { $0 > 1.5 }
                self.log.info("\(bigAccelerationsArray.debugDescription)")

                // NOTE: - Stop Session if some moving existed
                if bigAccelerationsArray.count > 0 {
                    WKInterfaceDevice.current().play(.stop)
                    timer.invalidate()
                    // NOTE: - User must be notified via System's Alarm tool about finishing
                    self.runtimeSession?.notifyUser(hapticType: .stop)
                    self.invalidate()
                }
            }
        })
        if let logTimer = logTimer {
            RunLoop.current.add(logTimer, forMode: .common)
        }
    }

}
