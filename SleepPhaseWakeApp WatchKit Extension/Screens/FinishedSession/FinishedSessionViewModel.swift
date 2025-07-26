//
//  FinishedSessionViewModel.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 09.06.2022.
//

import Combine
import SwiftUI

final class FinishedSessionViewModel: ObservableObject {
    
    // MARK: - PROPERTIES
    
    @AppStorage("measureState") private var state: MeasureState = .finished
    @AppStorage("wakeUpDate") private var wakeUpDate: Date = Date()
    
    var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Good Morning!"
        case 12..<17:
            return "Good Afternoon!"
        case 17..<22:
            return "Good Evening!"
        default:
            return "Good Night!"
        }
    }
    
    var wakeTimeMessage: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let actualWakeTime = formatter.string(from: Date())
        let plannedWakeTime = formatter.string(from: wakeUpDate)
        
        let minutesDifference = Int(Date().timeIntervalSince(wakeUpDate) / 60)
        if abs(minutesDifference) < 5 {
            return "Perfect timing! ✨"
        } else if minutesDifference < 0 {
            return "Woke up \(abs(minutesDifference)) min early"
        } else {
            return "Slept \(minutesDifference) min extra"
        }
    }
    
    // MARK: - METHODS
    
    func wakeUpDidSelected() {
        state = .noStarted
        SleepSessionCoordinatorService.shared.invalidate()
    }
    
    func recordSleepQuality(_ quality: String) {
        // This is a placeholder for future sleep quality tracking
        // Could integrate with HealthKit or custom analytics
        print("Sleep quality recorded: \(quality)")
    }
    
}
