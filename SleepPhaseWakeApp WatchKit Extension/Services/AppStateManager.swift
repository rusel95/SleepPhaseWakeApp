//
//  AppStateManager.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 04.08.2025.
//

import Foundation
import SwiftUI

enum MeasureState: String {
    case notStarted = "noStarted"
    case started = "started"
    case finished = "finished"
}

protocol StateManager: ObservableObject {
    var measureState: MeasureState { get set }
    var wakeUpDate: Date { get set }
    var isSimulationMode: Bool { get set }
    var startedDate: Date? { get set }
    var stoppedDate: Date? { get set }
    
    func reset()
}

final class AppStateManager: StateManager {
    static let shared = AppStateManager()
    
    @AppStorage("measureState") private var storedMeasureState: String = MeasureState.notStarted.rawValue
    @AppStorage("wakeUpDate") var wakeUpDate: Date = Date()
    @AppStorage("isSimulationMode") var isSimulationMode: Bool = false
    @AppStorage("startedDate") var startedDate: Date?
    @AppStorage("stoppedDate") var stoppedDate: Date?
    
    var measureState: MeasureState {
        get { MeasureState(rawValue: storedMeasureState) ?? .notStarted }
        set { storedMeasureState = newValue.rawValue }
    }
    
    private init() {}
    
    func reset() {
        measureState = .notStarted
        startedDate = nil
        stoppedDate = nil
    }
}