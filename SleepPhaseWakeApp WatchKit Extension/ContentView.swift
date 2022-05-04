//
//  ContentView.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 29.04.2022.
//

import Foundation
import SwiftUI
import CoreMotion

enum MeasureState {
    case noStarted
    case started
}

struct ContentView: View {

    @State var state: MeasureState = .noStarted

    private let recorder = CMSensorRecorder()
    private let defaultTimeInterval = TimeInterval(8*60)

//    private var lastSessionStart: Date? {
//        get {
//            let timeInterval = TimeInterval(UserDefaults.standard.integer(forKey: "lastSessionStartTimeInterval"))
//            return Date(timeIntervalSince1970: timeInterval)
//        }
//        set {
//
//        }
//    }


    var body: some View {
        VStack {
            Spacer()
            Text("Select Wake Up time:")
            Text("8 hour")
            Spacer()
            Button("Start") { startRecording() }
            Button("Print") { printData() }
        }
        .padding()
        .ignoresSafeArea()
        .background(Color.teal)
    }

    private func startRecording() {
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "lastSessionStartTimeInterval")

        DispatchQueue.global(qos: .background).async {
            self.recorder.recordAccelerometer(forDuration: defaultTimeInterval)
        }
    }

    private func printData() {
//        let lastSessionInterval = TimeInterval(UserDefaults.standard.integer(forKey: "lastSessionStartTimeInterval"))
//        if lastSessionInterval > 0,
//           let list = recorder.accelerometerData(from: Date(timeIntervalSince1970: lastSessionInterval), to: Date())?.enumerated() {
//            print("listing data")
//            for item in list {
//                guard let data = item.element as? CMRecordedAccelerometerData else { return }
//
//                print(data.startDate, data.acceleration.x, data.acceleration.y, data.acceleration.z)
//            }
//        }
        print("Start Printintg")
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            DispatchQueue.global(qos: .background).async {
                guard let list = recorder.accelerometerData(from: Date(timeIntervalSinceNow: TimeInterval(-1)),
                                                            to: Date())?.enumerated() else { return }

                for item in list {
                    guard let data = item.element as? CMRecordedAccelerometerData else { return }
                    let totalAcceleration = sqrt(data.acceleration.x * data.acceleration.x + data.acceleration.y * data.acceleration.y + data.acceleration.z * data.acceleration.z)
                    print(data.startDate, totalAcceleration)
                }
            }
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
