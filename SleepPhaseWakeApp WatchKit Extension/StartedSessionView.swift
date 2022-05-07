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
    @AppStorage("lastSessionStart") private var lastSessionStart: Date?

    private let recorder = CMSensorRecorder()
    private let defaultTimeInterval = TimeInterval(8*60)

    // MARK: - Body

    var body: some View {
        VStack {
            Spacer()
            Button("Stop") {
                state = .noStarted
                stopRecording()
            }
            Spacer()
        } //: VStack
        .padding()
        .ignoresSafeArea()
        .background(Color.indigo)
    }

}

// MARK: - Helpers

private extension StartedSessionView {

    func stopRecording() {
        if let lastSessionStart = lastSessionStart, lastSessionStart.timeIntervalSinceNow > 0,
           let list = recorder.accelerometerData(from: lastSessionStart, to: Date())?.enumerated() {
            print("listing data")
            for item in list {
                guard let data = item.element as? CMRecordedAccelerometerData else { return }

                let totalAcceleration = sqrt(data.acceleration.x * data.acceleration.x + data.acceleration.y * data.acceleration.y + data.acceleration.z * data.acceleration.z)
                print(data.startDate, data.acceleration.x, data.acceleration.y, data.acceleration.z, totalAcceleration)
            }
            self.lastSessionStart = nil
        }
    }

}

struct StartedSessionView_Previews: PreviewProvider {
    static var previews: some View {
        StartedSessionView()
    }
}
