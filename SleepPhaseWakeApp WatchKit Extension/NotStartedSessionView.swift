//
//  NotStartedSessionView.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 06.05.2022.
//

import SwiftUI
import CoreMotion

struct NotStartedSessionView: View {

    // MARK: - Property

    @AppStorage("measureState") var state: MeasureState = .noStarted
    @AppStorage("lastSessionStart") var lastSessionStart: Date?

    private let recorder = CMSensorRecorder()
    private let defaultTimeInterval = TimeInterval(8*60)

    // MARK: - Body

    var body: some View {
        Spacer()
        Text("Select Wake Up time:")
        Text("8 hour")
        Button("Start") {
            state = .started
            startRecording()
        }
        Spacer()
    }

    private func startRecording() {
        lastSessionStart = Date()

        if CMSensorRecorder.isAccelerometerRecordingAvailable() {
            DispatchQueue.global(qos: .background).async {
                self.recorder.recordAccelerometer(forDuration: defaultTimeInterval)
            }
        }
    }
    
}

struct NotStartedSessionView_Previews: PreviewProvider {
    static var previews: some View {
        NotStartedSessionView()
    }
}
