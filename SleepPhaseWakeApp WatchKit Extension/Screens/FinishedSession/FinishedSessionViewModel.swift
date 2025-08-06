//
//  FinishedSessionViewModel.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 09.06.2022.
//

import Combine
import SwiftUI

final class FinishedSessionViewModel: ObservableObject {
    
    private let stateManager: any StateManager
    private let sessionCoordinator: any SessionCoordinating
    
    init(
        stateManager: any StateManager = AppStateManager.shared,
        sessionCoordinator: any SessionCoordinating = SleepSessionCoordinatorService.shared
    ) {
        self.stateManager = stateManager
        self.sessionCoordinator = sessionCoordinator
    }
    
    // MARK: - PROPERTIES
    
    var wakeUpDate: Date {
        stateManager.wakeUpDate
    }
    
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
        _ = TimeFormatter.formatTime(Date())
        _ = TimeFormatter.formatTime(wakeUpDate)
        
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
        stateManager.reset()
        sessionCoordinator.invalidate()
    }
    
    func recordSleepQuality(_ quality: String) {
        // This is a placeholder for future sleep quality tracking
        // Could integrate with HealthKit or custom analytics
        print("Sleep quality recorded: \(quality)")
    }
    
}
