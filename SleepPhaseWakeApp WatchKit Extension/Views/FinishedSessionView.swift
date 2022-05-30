//
//  FinishedSessionView.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 30.05.2022.
//

import SwiftUI

struct FinishedSessionView: View {

    // MARK: - PROPERTY

    @AppStorage("measureState") private var state: MeasureState = .finished

    // MARK: - BODY
    var body: some View {
        VStack {
            Spacer()

            Image(systemName: "sun.and.horizon.fill")
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(Color.yellow)
                .font(.system(size: 56, weight: .semibold))

            Spacer()

            Text("Good Morning!")
                .foregroundColor(.white)
                .font(.system(size: 24, weight: .semibold))

            Spacer()

            Button(action: {
                withAnimation(.easeIn(duration: Constants.defaultAnimationDuration)) {
                    state = .noStarted
                }
                triggerWakeUp()
            }, label: {
                Label("WAKE UP", systemImage: "bolt.fill")
                    .font(.system(size: 20, weight: .semibold))
            })

            Spacer()
        }
        .background(Constants.defaultBackgroundColor)
        .ignoresSafeArea()
    }

}

// MARK: - HELPERS

private extension FinishedSessionView {

    func triggerWakeUp() {
        SleepSessionCoordinatorService.shared.invalidate()
    }

}


// MARK: - PREVIEW
struct FinishedSessionView_Previews: PreviewProvider {
    static var previews: some View {
        FinishedSessionView()
    }
}
