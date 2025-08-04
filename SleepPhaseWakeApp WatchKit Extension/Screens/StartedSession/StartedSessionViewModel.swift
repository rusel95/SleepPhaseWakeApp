//
//  StartedSessionViewModel.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 08.06.2022.
//

import Combine
import WatchKit
import SwiftUI

final class StartedSessionViewModel: ObservableObject {
    
    // MARK: - PROPERTIES
    
    @Published var isAlertPresented: Bool = false
    @Published var progressToWakeUp: Double = 0.0
    @Published var remainingTime: String = "--:--"
    @Published var isMonitoring: Bool = false
    
    var wakeUpWindowsDescription: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        // NOTE: Simulation Processing Time is 30 seconds
        let processingIntervalDuration = isSimulationMode ? 30 : Constants.defaultProcessingDuration
        let minimumWakeUpDate = wakeUpDate.addingTimeInterval(-processingIntervalDuration)
        let intervalStartString = formatter.string(from: minimumWakeUpDate)
        let intervalEndString = formatter.string(from: wakeUpDate)
        return "\(intervalStartString) - \(intervalEndString)"
    }
    
    var alertDescription: String {
        "Minimum recommended battery level for proper Sleep Phase detection is \(Int(minimumBatteryLevel * 100))%"
    }
    
    private let minimumBatteryLevel: Float = 0.2
    private var timer: Timer?
    
    var isSimulationMode: Bool {
        stateManager.isSimulationMode
    }
    
    var wakeUpDate: Date {
        stateManager.wakeUpDate
    }
    
    private let stateManager = AppStateManager.shared
    private let sessionManager = SleepSessionCoordinatorService.shared
    
    // MARK: - INIT
    
    init() {
        showLowBatteryLevelAlertIfNeeded()
    }
    
    // MARK: - METHODS
    
    func showLowBatteryLevelAlertIfNeeded() {
        WKInterfaceDevice.current().isBatteryMonitoringEnabled = true
        if WKInterfaceDevice.current().batteryLevel < minimumBatteryLevel {
            isAlertPresented = true
        }
        WKInterfaceDevice.current().isBatteryMonitoringEnabled = false
    }
    
    func startMonitoring() {
        isMonitoring = true
        updateProgress()
        
        // Update progress every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
    }
    
    private func updateProgress() {
        let now = Date()
        let processingIntervalDuration = isSimulationMode ? 30.0 : Constants.defaultProcessingDuration
        let minimumWakeUpDate = wakeUpDate.addingTimeInterval(-processingIntervalDuration)
        
        if now >= wakeUpDate {
            progressToWakeUp = 1.0
            remainingTime = "00:00"
        } else if now <= minimumWakeUpDate {
            progressToWakeUp = 0.0
            remainingTime = TimeFormatter.formatCountdown(from: now, to: wakeUpDate)
        } else {
            let totalDuration = processingIntervalDuration
            let elapsed = now.timeIntervalSince(minimumWakeUpDate)
            progressToWakeUp = min(elapsed / totalDuration, 1.0)
            
            remainingTime = TimeFormatter.formatCountdown(from: now, to: wakeUpDate)
        }
    }
    
    func stopDidSelected() {
        timer?.invalidate()
        timer = nil
        isMonitoring = false
        stateManager.measureState = .notStarted
        sessionManager.invalidate()
    }
    
    deinit {
        timer?.invalidate()
    }
    
}
