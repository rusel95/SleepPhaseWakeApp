//
//  ContentView.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 29.04.2022.
//

import Foundation
import SwiftUI
import CoreMotion

enum MeasureState: String {
    case noStarted
    case started
}

struct ContentView: View {

    // MARK: - Property

    @AppStorage("measureState") var state: MeasureState = .noStarted
    @AppStorage("lastSessionStart") var lastSessionStart: Date?

    private let recorder = CMSensorRecorder()
    private let defaultTimeInterval = TimeInterval(8*60)

    // MARK: - Body

    var body: some View {
        VStack {
            switch state {
            case .noStarted:
                Spacer()
                Text("Select Wake Up time:")
                Text("8 hour")
                Button("Start") {
                    state = .started
                    startRecording()
                }
                Spacer()
            case .started:
                Spacer()
                Button("Stop") {
                    state = .noStarted
                    stopRecording()
                }
                Spacer()
            }

        }
        .padding()
        .ignoresSafeArea()
        .background(Color.teal)

    }

    private func startRecording() {
        lastSessionStart = Date()

        if CMSensorRecorder.isAccelerometerRecordingAvailable() {
            DispatchQueue.global(qos: .background).async {
                self.recorder.recordAccelerometer(forDuration: defaultTimeInterval)
            }
        }
    }

    private func stopRecording() {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
