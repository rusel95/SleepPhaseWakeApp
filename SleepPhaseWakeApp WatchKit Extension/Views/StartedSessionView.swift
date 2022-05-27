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
    @AppStorage("wakeUpDate") private var wakeUpDate: Date = Date() // default value should never be used

    private var wakeUpWindowsDescription: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let intervalStartString = formatter.string(from: wakeUpDate.addingTimeInterval(-Constants.defaultProcessingDuration))
        let intervalEndString = formatter.string(from: wakeUpDate)
        return "\(intervalStartString) - \(intervalEndString)"
    }

    // MARK: - Body

    var body: some View {
        VStack {
            Spacer()

            Image(systemName: "alarm")
                .foregroundColor(Color.white)
                .font(.system(size: 55, weight: .bold))

            Spacer()

            Text("is set between")
                .fontWeight(.regular)

            Spacer()

            Text(wakeUpWindowsDescription)
                .fontWeight(.bold)

            Spacer()
            
            Button(
                role: .cancel,
                action: {
                    withAnimation(.easeIn(duration: Constants.defaultAnimationDuration)) {
                        state = .noStarted
                    }
                    triggerSleepSessionStop()
                }, label: {
                    Label("stop", systemImage: "stop.fill")
                })
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

    func triggerSleepSessionStop() {
        SleepSessionCoordinatorService.shared.invalidate()
    }

}

// MARK: - Preview

struct StartedSessionView_Previews: PreviewProvider {

    static var previews: some View {
        StartedSessionView()
    }

}
