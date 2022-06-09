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
    
    @AppStorage("isSimulationMode") private var isSimulationMode: Bool = false
    @AppStorage("wakeUpDate") private var wakeUpDate: Date = Date() // default value should never be used
    @AppStorage("measureState") private var state: MeasureState = .started
    
    private let sleepSessionService = SleepSessionCoordinatorService.shared
    
    // MARK: - INIT
    
    init() {
        showLowBatteryLevelAlertIfNeeded()
    }
    
    // MARK: - METHODS
    
    func showLowBatteryLevelAlertIfNeeded() {
        WKInterfaceDevice.current().isBatteryMonitoringEnabled = true
        if WKInterfaceDevice.current().batteryLevel < 0.2 {
            isAlertPresented = true
        }
        WKInterfaceDevice.current().isBatteryMonitoringEnabled = false
    }
    
    func stopDidSelected() {
        state = .noStarted
        sleepSessionService.invalidate()
    }
    
}
