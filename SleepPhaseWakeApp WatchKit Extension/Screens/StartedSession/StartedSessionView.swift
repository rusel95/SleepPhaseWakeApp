//
//  StartedSessionView.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 06.05.2022.
//

import SwiftUI
import CoreMotion

struct StartedSessionView: View {

    // MARK: - PROPERTIES

    @ObservedObject private var viewModel: StartedSessionViewModel = StartedSessionViewModel()

    // MARK: - BODY

    var body: some View {
        VStack {
            Spacer()

            Image(systemName: "alarm")
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(Color.teal)
                .font(.system(size: 56, weight: .semibold))

            Spacer()

            Text("is set between")
                .fontWeight(.regular)

            Spacer()

            Text(viewModel.wakeUpWindowsDescription)
                .fontWeight(.bold)

            Spacer()
            
            Button(role: .cancel,
                   action: {
                withAnimation(.easeIn(duration: Constants.defaultAnimationDuration)) {
                    viewModel.stopDidSelected()
                }
            }, label: {
                Label("STOP", systemImage: "stop.fill")
            })
        } //: VStack
        .foregroundColor(Color.gray)
        .padding()
        .ignoresSafeArea(.container, edges: .bottom)
        .alert(viewModel.alertDescription, isPresented: $viewModel.isAlertPresented) {}
    }

}

// MARK: - PREVIEW

struct StartedSessionView_Previews: PreviewProvider {

    static var previews: some View {
        StartedSessionView()
    }

}
