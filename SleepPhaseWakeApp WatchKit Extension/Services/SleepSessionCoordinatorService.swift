//
//  SleepSessionCoordinatorService.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 18.05.2022.
//

import SwiftUI
import CoreMotion
import OSLog

enum MeasureState: String {

    case noStarted
    case started
    case finished

}

final class SleepSessionCoordinatorService: NSObject {

    // MARK: - PROPERTY

    static let shared: SleepSessionCoordinatorService = SleepSessionCoordinatorService()
    
    private var runtimeSession: WKExtendedRuntimeSession?
    private var processingTimer: Timer?

    @AppStorage("measureState") private var state: MeasureState = .started
    @AppStorage("lastSessionStart") private var lastSessionStart: Date?
    @AppStorage("wakeUpDate") private var wakeUpDate: Date = Date() // default value should never be used
    @AppStorage("isSimulationMode") private var isSimulationMode: Bool = false

    private let sensorRecorder = CMSensorRecorder()

    private let simulationDuration = TimeInterval(60) // 1 minute
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "SleepSessionCoordinatorService")

    // MARK: - INIT

    private override init() {}

    deinit {
        logger.error("SleepSessionCoordinatorService deinited")
    }

    // MARK: - METHODS

    func start() {
        guard runtimeSession?.state != .running else { return }

        logger.info("Sleep Session started")

        WKInterfaceDevice.current().play(.start)

        // NOTE: Create or recreate session if needed
        if runtimeSession == nil || runtimeSession?.state == .invalid {
            runtimeSession = WKExtendedRuntimeSession()
        }
        runtimeSession?.delegate = self

        // NOTE: Should start 30 minutes before wake time
        let processingSessionStartDate = isSimulationMode
            ? Date().addingTimeInterval(simulationDuration / 2.0) // 30 seconds before finish time
        : wakeUpDate.addingTimeInterval(-Constants.defaultProcessingDuration)
        runtimeSession?.start(at: processingSessionStartDate)

        lastSessionStart = Date()

        if CMSensorRecorder.isAccelerometerRecordingAvailable() {
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                guard let self = self else { return }

                let accelerometerRecordingDuration = self.isSimulationMode ? self.simulationDuration : self.wakeUpDate.timeIntervalSinceNow
                self.sensorRecorder.recordAccelerometer(forDuration: accelerometerRecordingDuration)
            }
        }
    }

    func invalidate() {
        logger.info("Sleep Session Stopped")
        processingTimer?.invalidate()
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
        logger.info("Session invalidated with reason: \(reason.rawValue), error: \(error.debugDescription)")
    }

    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        logger.info("Session Started")
        WKInterfaceDevice.current().play(.click)
        scheduleDataProcessing()
    }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        logger.error("Session will expire")
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
        logger.info("Data Processing started")
        processingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            // NOTE: click sound for testing puproses for clearness of background work
            if self.isSimulationMode {
                WKInterfaceDevice.current().play(.click)
            }

            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                guard let self = self,
                      let list = self.sensorRecorder.accelerometerData(from: Date().addingTimeInterval(TimeInterval(-1)), to: Date())?.enumerated(),
                      self.runtimeSession?.state == .running else { return }

                /* Phase detection Version 0.0.1
                    Currently we are using just very simple shake detection for discovering Sleep Phase - Once user moved we Wake him up
                    In the futire is is possible that we will use:
                       - Heart Rate
                       - HealthKit sleep analyse
                */
                let accelerometerDataArray = list.compactMap { $0.element as? CMRecordedAccelerometerData }
                let totalAccelerationsArray = accelerometerDataArray
                    .map { sqrt(pow($0.acceleration.x, 2) + pow($0.acceleration.y, 2) + pow($0.acceleration.z, 2)) }

                // NOTE: 1.2 is a temporary constant - detects only fast moves approximately
                let bigAccelerationsArray = totalAccelerationsArray.filter { $0 > 1.2 }

                // NOTE: - Stop Session if some moving existed
                if bigAccelerationsArray.count > 0 {
                    self.logger.info("\(bigAccelerationsArray.debugDescription)")
                    WKInterfaceDevice.current().play(.stop)
                    timer.invalidate()
                    // NOTE: - User must be notified via System's Alarm tool about finishing
                    self.runtimeSession?.notifyUser(hapticType: .stop)
                    self.state = .finished
                }
            }
        })
        if let logTimer = processingTimer {
            RunLoop.current.add(logTimer, forMode: .common)
        }
    }

}
