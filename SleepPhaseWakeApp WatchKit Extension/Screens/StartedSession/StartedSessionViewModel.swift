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
    
    @AppStorage("isSimulationMode") private var isSimulationMode: Bool = false
    @AppStorage("wakeUpDate") private var wakeUpDate: Date = Date() // default value should never be used
    @AppStorage("measureState") private var state: MeasureState = .started
    
    private let sleepSessionService = SleepSessionCoordinatorService.shared
    private let minimumBatteryLevel: Float = 0.2
    private var timer: Timer?
    
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
            let totalSeconds = Int(wakeUpDate.timeIntervalSince(now))
            let hours = totalSeconds / 3600
            let minutes = (totalSeconds % 3600) / 60
            remainingTime = String(format: "%02d:%02d", hours, minutes)
        } else {
            let totalDuration = processingIntervalDuration
            let elapsed = now.timeIntervalSince(minimumWakeUpDate)
            progressToWakeUp = min(elapsed / totalDuration, 1.0)
            
            let remainingSeconds = Int(wakeUpDate.timeIntervalSince(now))
            let minutes = remainingSeconds / 60
            let seconds = remainingSeconds % 60
            remainingTime = String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    func stopDidSelected() {
        timer?.invalidate()
        timer = nil
        isMonitoring = false
        state = .noStarted
        sleepSessionService.invalidate()
    }
    
    deinit {
        timer?.invalidate()
    }
    
}
