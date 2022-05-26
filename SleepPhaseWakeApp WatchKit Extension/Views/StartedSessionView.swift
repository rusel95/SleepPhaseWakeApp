//
//  StartedSessionView.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 06.05.2022.
//

import SwiftUI
import CoreMotion

struct StartedSessionView: View {

    // MARK: - Property

    @AppStorage("measureState") private var state: MeasureState = .started

    // MARK: - Body

    var body: some View {
        VStack {
            Spacer()
            Button("Stop") {
                withAnimation(.easeIn(duration: 0.3)) {
                    state = .noStarted
                }
                stopRecording()
            }
            Spacer()
        } //: VStack
        .padding()
        .ignoresSafeArea()
        .background(Color.indigo)
        .onAppear {
            SleepSessionCoordinatorService.shared.start()
        }
    }

}

// MARK: - Helpers

private extension StartedSessionView {

    func stopRecording() {
        SleepSessionCoordinatorService.shared.invalidate()
    }

}

// MARK: - Preview

struct StartedSessionView_Previews: PreviewProvider {

    static var previews: some View {
        StartedSessionView()
    }

}
