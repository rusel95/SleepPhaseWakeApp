//
//  ContentView.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 29.04.2022.
//

import Foundation
import SwiftUI
import WatchKit

struct ContentView: View {

    // MARK: - Property

    @StateObject private var stateManager = AppStateManager.shared

    // MARK: - Body

    var body: some View {
        switch stateManager.measureState {
        case .notStarted:
            NotStartedSessionView()
        case .started:
            StartedSessionView()
        case .finished:
            FinishedSessionView()
        }
    }

}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        ContentView()
    }

}

// MARK: - UI Components moved to separate files
