//
//  StartedSessionView.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 06.05.2022.
//

import SwiftUI
import CoreMotion
import WatchKit

struct StartedSessionView: View {

    // MARK: - PROPERTIES

    @StateObject private var viewModel = StartedSessionViewModel()
    @State private var showingStopConfirmation = false

    // MARK: - BODY

    var body: some View {
        VStack(spacing: Theme.Spacing.medium) {
            // Simplified time display
            VStack(spacing: Theme.Spacing.xSmall) {
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: Theme.Sizes.largeIconSize))
                    .foregroundColor(Theme.Colors.primary)
                    .symbolRenderingMode(.hierarchical)
                
                Text(viewModel.remainingTime)
                    .font(Theme.Typography.largeTitle)
                    .foregroundColor(Theme.Colors.primaryText)
                
                Text("until wake window")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.secondaryText)
            }
            .padding(.top, Theme.Spacing.small)
            
            // Wake Window
            Text(viewModel.wakeUpWindowsDescription)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.primaryText)
                .multilineTextAlignment(.center)
            
            // Status
            HStack(spacing: Theme.Spacing.xSmall) {
                Circle()
                    .fill(Theme.Colors.success)
                    .frame(width: 6, height: 6)
                    .overlay(
                        Circle()
                            .fill(Theme.Colors.success.opacity(0.3))
                            .frame(width: 12, height: 12)
                            .scaleEffect(viewModel.isMonitoring ? 1.5 : 1)
                            .animation(
                                Theme.Animation.smooth
                                    .repeatForever(autoreverses: true),
                                value: viewModel.isMonitoring
                            )
                    )
                
                Text("Monitoring")
                    .font(Theme.Typography.footnote)
                    .foregroundColor(Theme.Colors.secondaryText)
            }
            
            Spacer()
            
            // Stop Button - Simplified and larger tap target
            Button(action: {
                HapticFeedback.warning()
                showingStopConfirmation = true
            }) {
                Label("Stop", systemImage: "stop.fill")
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.error)
            }
            .buttonStyle(PlainButtonStyle())
            .frame(maxWidth: .infinity)
            .frame(height: Theme.Sizes.buttonHeight)
            .background(
                RoundedRectangle(cornerRadius: Theme.Sizes.smallCornerRadius)
                    .stroke(Theme.Colors.error.opacity(0.5), lineWidth: 1)
            )
        }
        .padding(Theme.Spacing.small)
        .alert("Stop Sleep Tracking?", isPresented: $showingStopConfirmation) {
            Button("Cancel", role: .cancel) {
                HapticFeedback.selection()
            }
            Button("Stop", role: .destructive) {
                HapticFeedback.error()
                viewModel.stopDidSelected()
            }
        } message: {
            Text("Are you sure you want to stop tracking your sleep?")
        }
        .alert(viewModel.alertDescription, isPresented: $viewModel.isAlertPresented) {
            Button("OK") {
                HapticFeedback.selection()
            }
        }
        .onAppear {
            viewModel.startMonitoring()
        }
    }

}

// MARK: - PREVIEW

struct StartedSessionView_Previews: PreviewProvider {

    static var previews: some View {
        StartedSessionView()
    }

}
