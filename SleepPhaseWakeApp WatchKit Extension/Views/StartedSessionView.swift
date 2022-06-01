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
    @AppStorage("isSimulationMode") private var isSimulationMode: Bool = false

    @State private var isAlertPresented: Bool = false

    private var wakeUpWindowsDescription: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        // NOTE: Simulation Processing Time is 30 seconds
        let processingIntervalDuration = isSimulationMode ? 30 : Constants.defaultProcessingDuration
        let minimumWakeUpDate = wakeUpDate.addingTimeInterval(-processingIntervalDuration)
        let intervalStartString = formatter.string(from: minimumWakeUpDate)
        let intervalEndString = formatter.string(from: wakeUpDate)
        return "\(intervalStartString) - \(intervalEndString)"
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

            Text(wakeUpWindowsDescription)
                .fontWeight(.bold)

            Spacer()
            
            Button(role: .cancel,
                   action: {
                withAnimation(.easeIn(duration: Constants.defaultAnimationDuration)) {
                    state = .noStarted
                }
                triggerSleepSessionStop()
            }, label: {
                Label("STOP", systemImage: "stop.fill")
            })
        } //: VStack
        .foregroundColor(Color.gray)
        .padding()
        .ignoresSafeArea(.container, edges: .bottom)
        .onAppear {
            SleepSessionCoordinatorService.shared.start()
            showLowBatteryLevelAlertIfNeeded()
        }
        .alert("Minimum recommened battery level for proper Sleep Phase detection is 20%", isPresented: $isAlertPresented) {}
    }

}

// MARK: - Helpers

private extension StartedSessionView {

    func triggerSleepSessionStop() {
        SleepSessionCoordinatorService.shared.invalidate()
    }

    func showLowBatteryLevelAlertIfNeeded() {
        WKInterfaceDevice.current().isBatteryMonitoringEnabled = true
        if WKInterfaceDevice.current().batteryLevel < 0.2 {
            isAlertPresented = true
        }
        WKInterfaceDevice.current().isBatteryMonitoringEnabled = false
    }

}

// MARK: - Preview

struct StartedSessionView_Previews: PreviewProvider {

    static var previews: some View {
        StartedSessionView()
    }

}
