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

    @ObservedObject var viewModel: StartedSessionViewModel
    
    init() {
        self.viewModel = StartedSessionViewModel()
    }

    // MARK: - Body

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
        .alert("Minimum recommened battery level for proper Sleep Phase detection is 20%", isPresented: $viewModel.isAlertPresented) {}
    }

}

// MARK: - Preview

struct StartedSessionView_Previews: PreviewProvider {

    static var previews: some View {
        StartedSessionView()
    }

}
