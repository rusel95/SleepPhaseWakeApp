//
//  ContentView.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 29.04.2022.
//

import Foundation
import SwiftUI

enum MeasureState: String {
    case noStarted
    case started
}

struct ContentView: View {

    // MARK: - Property

    @AppStorage("measureState") var state: MeasureState = .noStarted

    // MARK: - Body

    var body: some View {
        VStack {
            switch state {
            case .noStarted:
                NotStartedSessionView()
            case .started:
                StartedSessionView()
            }

        } //: VStack
        .padding()
        .ignoresSafeArea()
        .background(Color.teal)
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
