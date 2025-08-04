//
//  NotStartedSessionView.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 06.05.2022.
//

import SwiftUI
import WatchKit

struct NotStartedSessionView: View {

    // MARK: - PROPERTIES

    @State private var isSlideActivated = false
    @StateObject private var viewModel = NotStartedSessionViewModel()
    
    // MARK: - BODY

    var body: some View {
        VStack(spacing: Theme.Adaptive.Spacing.small) {
            // Header - Simplified with reduced top spacing
            Text("Wake Time")
                .font(Theme.Adaptive.Typography.headline)
                .foregroundColor(Theme.Colors.primaryText)
                .padding(.top, -Theme.Adaptive.Spacing.small)
                .gesture(
                    LongPressGesture(minimumDuration: 1.0)
                        .onEnded { _ in
                            HapticFeedback.success()
                            viewModel.longTapDetected()
                        }
                )

            // Time Picker - Using reusable component
            SleepTimePicker(hour: $viewModel.selectedHour, minute: $viewModel.selectedMinute)
                .padding(.vertical, Theme.Adaptive.Spacing.small)
                .onChange(of: viewModel.selectedHour) { _ in
                    HapticFeedback.selection()
                }
                .onChange(of: viewModel.selectedMinute) { _ in
                    HapticFeedback.selection()
                }
            
            Text("30 min window")
                .font(Theme.Adaptive.Typography.body)
                .foregroundColor(Theme.Colors.secondaryText)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
                .padding(.top, -Theme.Adaptive.Spacing.small)

            Spacer(minLength: Theme.Adaptive.Spacing.small)
            
            // Slide to Start Button - Using reusable component
            SlideToStartButton(
                isActivated: $isSlideActivated,
                onActivate: {
                    viewModel.startDidSelected()
                }
            )
            
            if viewModel.isSimulationMode {
                Text("Sim Mode")
                    .font(Theme.Adaptive.Typography.body)
                    .foregroundColor(Theme.Colors.warning)
            }
        } //: VStack
        .adaptivePadding()
        .onAppear {
            viewModel.viewDidAppear()
        }
    }

}

// MARK: - PREVIEW

struct NotStartedSessionView_Previews: PreviewProvider {

    static var previews: some View {
        NotStartedSessionView()
    }

}
