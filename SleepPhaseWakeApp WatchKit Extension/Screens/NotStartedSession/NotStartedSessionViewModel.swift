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
    
    @AppStorage("isSimulationMode") private(set) var isSimulationMode: Bool = false
    
    @Published private(set) var isAnimating: Bool = false
    
    @AppStorage("measureState") private var state: MeasureState = .noStarted
    @AppStorage("wakeUpDate") private var wakeUpDate: Date = Date() // default value should never be used

    private(set) var hours: [String] = (0 ... 23).map { String($0) }
    private(set) var minutes: [String] = (0 ... 59).map { String($0) }
    
    private let sleepSessionService = SleepSessionCoordinatorService.shared
   
    // MARK: - METHODS
    
    init() {
        isAnimating = true
    }
    
    func longTapDetected() {
        isSimulationMode.toggle()
    }
    
    func viewDidAppear() {
        withAnimation {
            isAnimating = true
        }
    }
    
    func startDidSelected() {
        if let currentDayWakeUpDate = Calendar.current.date(bySettingHour: selectedHour,
                                                            minute: selectedMinute,
                                                            second: 0,
                                                            of: Date()),
           currentDayWakeUpDate > Date() {
            wakeUpDate = currentDayWakeUpDate
        } else if let nextDayDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()),
                  let nextDayWakeUpDate = Calendar.current.date(bySettingHour: selectedHour,
                                                                minute: selectedMinute,
                                                                second: 0,
                                                                of: Calendar.current.startOfDay(for: nextDayDate)) {
            wakeUpDate = nextDayWakeUpDate
        }
        sleepSessionService.start()
        state = .started
    }
    
}
