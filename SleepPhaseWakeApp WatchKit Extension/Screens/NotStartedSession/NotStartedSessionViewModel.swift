//
//  NotStartedSessionViewModel.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 09.06.2022.
//

import Combine
import SwiftUI

final class NotStartedSessionViewModel: ObservableObject {
    
    // MARK: - PROPERTIES
    
    @AppStorage("selectedHour") var selectedHour: Int = 8
    @AppStorage("selectedMinute") var selectedMinute: Int = 0
    
    @Published private(set) var isAnimating: Bool = false
    
    private(set) var hours: [String] = (0 ... 23).map { String($0) }
    private(set) var minutes: [String] = (0 ... 59).map { String($0) }
    
    var isSimulationMode: Bool {
        stateManager.isSimulationMode
    }
   
    // MARK: - METHODS
    
    private let stateManager = AppStateManager.shared
    private let sessionManager = SleepSessionCoordinatorService.shared
    
    init() {
        isAnimating = true
    }
    
    func longTapDetected() {
        stateManager.isSimulationMode.toggle()
    }
    
    func viewDidAppear() {
        withAnimation {
            isAnimating = true
        }
    }
    
    func startDidSelected() {
        let wakeUpDate = calculateWakeUpDate()
        stateManager.wakeUpDate = wakeUpDate
        sessionManager.start()
        stateManager.measureState = .started
    }
    
    private func calculateWakeUpDate() -> Date {
        if let currentDayWakeUpDate = Calendar.current.date(bySettingHour: selectedHour,
                                                            minute: selectedMinute,
                                                            second: 0,
                                                            of: Date()),
           currentDayWakeUpDate > Date() {
            return currentDayWakeUpDate
        } else if let nextDayDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()),
                  let nextDayWakeUpDate = Calendar.current.date(bySettingHour: selectedHour,
                                                                minute: selectedMinute,
                                                                second: 0,
                                                                of: Calendar.current.startOfDay(for: nextDayDate)) {
            return nextDayWakeUpDate
        }
        
        return Date()
    }
    
}
