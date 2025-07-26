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
        VStack(spacing: Theme.Spacing.small) {
            // Header - Simplified
            Text("Wake Time")
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.primaryText)
                .gesture(
                    LongPressGesture(minimumDuration: 1.0)
                        .onEnded { _ in
                            HapticFeedback.success()
                            viewModel.longTapDetected()
                        }
                )

            // Time Picker - Simplified
            HStack {
                Picker(selection: $viewModel.selectedHour, label: Text("")) {
                    ForEach(0..<24) { h in
                        Text(String(format: "%02d", h))
                            .tag(h)
                    }
                }
                .frame(width: 50)
                .labelsHidden()
                
                Text(":")
                    .font(Theme.Typography.title)
                
                Picker(selection: $viewModel.selectedMinute, label: Text("")) {
                    ForEach(0..<60) { m in
                        Text(String(format: "%02d", m))
                            .tag(m)
                    }
                }
                .frame(width: 50)
                .labelsHidden()
            }
            .onChange(of: viewModel.selectedHour) { _ in
                HapticFeedback.selection()
            }
            .onChange(of: viewModel.selectedMinute) { _ in
                HapticFeedback.selection()
            }
            
            Text("30 min window")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.secondaryText)

            Spacer()
            
            // Simplified Slide Button
            ZStack {
                RoundedRectangle(cornerRadius: Theme.Sizes.cornerRadius)
                    .fill(Theme.Colors.sliderTrack)
                    .frame(height: Theme.Sizes.sliderHeight)
                
                HStack {
                    Spacer()
                    Text("Slide to Start")
                        .font(Theme.Typography.callout)
                        .foregroundColor(Theme.Colors.secondaryText)
                    Image(systemName: "chevron.right.2")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.Colors.secondaryText)
                    Spacer()
                }
            }
            .onTapGesture {
                // Fallback tap to start for easier interaction
                HapticFeedback.success()
                viewModel.startDidSelected()
            }
            .gesture(
                DragGesture(minimumDistance: 50)
                    .onEnded { value in
                        if value.translation.width > 50 {
                            HapticFeedback.success()
                            viewModel.startDidSelected()
                        }
                    }
            )
            
            if viewModel.isSimulationMode {
                Text("Sim Mode")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.warning)
            }
        } //: VStack
        .padding(Theme.Spacing.small)
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
