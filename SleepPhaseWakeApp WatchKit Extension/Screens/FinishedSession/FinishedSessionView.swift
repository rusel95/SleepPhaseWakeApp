//
//  FinishedSessionView.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 30.05.2022.
//

import SwiftUI

struct FinishedSessionView: View {

    // MARK: - PROPERTIES

    @ObservedObject private var viewModel: FinishedSessionViewModel = FinishedSessionViewModel()

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
                .frame(alignment: .center)
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            Spacer()

            Button(action: {
                withAnimation(.easeIn(duration: Constants.defaultAnimationDuration)) {
                    viewModel.wakeUpDidSelected()
                }
            }, label: {
                Label("WAKE UP", systemImage: "bolt.fill")
                    .font(.system(size: 20, weight: .semibold))
            })
            Spacer()
        }
        .padding()
        .background(Constants.defaultBackgroundColor)
        .ignoresSafeArea(.container, edges: .bottom)
    }

}

// MARK: - PREVIEW
struct FinishedSessionView_Previews: PreviewProvider {
    static var previews: some View {
        FinishedSessionView()
    }
}
