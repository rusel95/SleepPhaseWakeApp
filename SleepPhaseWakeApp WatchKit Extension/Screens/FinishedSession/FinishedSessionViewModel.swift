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
    
    // MARK: - METHODS
    
    func wakeUpDidSelected() {
        state = .noStarted
        SleepSessionCoordinatorService.shared.invalidate()
    }
    
}
