//
//  MovementMonitor.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 04.08.2025.
//

import Foundation
import CoreMotion
import OSLog
import WatchKit

protocol MovementMonitoring {
    func startMonitoring(onWakeUpDetected: @escaping () -> Void)
    func stopMonitoring()
}

final class MovementMonitor: MovementMonitoring {
    private var processingTimer: Timer?
    private let accelerometerService: SensorDataProvider
    private let movementDetector: AccelerometerDataHandler
    private let stateManager: any StateManager
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "MovementMonitor")
    
    private var onWakeUpDetected: (() -> Void)?
    
    init(
        accelerometerService: SensorDataProvider = AccelerometerService.shared,
        movementDetector: AccelerometerDataHandler = MovementDetector(),
        stateManager: any StateManager = AppStateManager.shared
    ) {
        self.accelerometerService = accelerometerService
        self.movementDetector = movementDetector
        self.stateManager = stateManager
    }
    
    func startMonitoring(onWakeUpDetected: @escaping () -> Void) {
        self.onWakeUpDetected = onWakeUpDetected
        logger.info("Movement monitoring started")
        
        processingTimer = Timer.scheduledTimer(
            withTimeInterval: AppConfiguration.SleepTracking.dataProcessingInterval,
            repeats: true
        ) { [weak self] timer in
            self?.checkForMovement(timer: timer)
        }
        
        if let timer = processingTimer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    func stopMonitoring() {
        processingTimer?.invalidate()
        processingTimer = nil
        onWakeUpDetected = nil
        logger.info("Movement monitoring stopped")
    }
    
    private func checkForMovement(timer: Timer) {
        if stateManager.isSimulationMode {
            HapticFeedback.selection()
        }
        
        let queryStartDate = Date().addingTimeInterval(-AppConfiguration.SleepTracking.accelerometerLookbackTime)
        let queryEndDate = Date()
        
        accelerometerService.queryRecordedData(from: queryStartDate, to: queryEndDate) { [weak self] dataList in
            guard let self = self,
                  let dataList = dataList else { return }
            
            for list in dataList {
                for data in list {
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
        
        if stateManager.isSimulationMode {
            HapticFeedback.impact(.stop)
        }
        
        timer.invalidate()
        onWakeUpDetected?()
    }
}