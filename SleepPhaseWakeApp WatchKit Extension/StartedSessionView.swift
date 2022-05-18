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

    @Environment(\.scenePhase) var scenePhase

    private let recorder = CMSensorRecorder()
    private let defaultTimeInterval = TimeInterval(2*60)
    private let sessionCoordinator = SessionCoordinator()

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
            sessionCoordinator.start()
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                debugPrint("working", Date())
            })
        }
    }

}

// MARK: - Helpers

private extension StartedSessionView {

    func stopRecording() {
        logAccelerometerData()
        sessionCoordinator.invalidate()
        lastSessionStart = nil
    }

    func logAccelerometerData() {
        guard let lastSessionStart = lastSessionStart, lastSessionStart.timeIntervalSinceNow > 0,
              let list = recorder.accelerometerData(from: lastSessionStart, to: Date())?.enumerated() else { return }

        for item in list {
            guard let data = item.element as? CMRecordedAccelerometerData else { return }

            let totalAcceleration = sqrt(data.acceleration.x * data.acceleration.x + data.acceleration.y * data.acceleration.y + data.acceleration.z * data.acceleration.z)
            print(data.startDate, data.acceleration.x, data.acceleration.y, data.acceleration.z, totalAcceleration)
        }
    }

}

// MARK: - Preview

struct StartedSessionView_Previews: PreviewProvider {

    static var previews: some View {
        StartedSessionView()
    }

}
