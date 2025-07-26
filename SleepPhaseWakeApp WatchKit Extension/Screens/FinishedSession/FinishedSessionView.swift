//
//  FinishedSessionView.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 30.05.2022.
//

import SwiftUI
import WatchKit

struct FinishedSessionView: View {

    // MARK: - PROPERTIES

    @StateObject private var viewModel = FinishedSessionViewModel()
    @State private var isAnimating = false
    @State private var sunRotation = 0.0

    // MARK: - BODY
    
    var body: some View {
        VStack(spacing: Theme.Spacing.medium) {
            Spacer()
            
            // Simple sun icon
            Image(systemName: "sun.max.fill")
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 40))
                .scaleEffect(isAnimating ? 1.1 : 0.9)
                .animation(
                    Theme.Animation.smooth
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            // Greeting
            VStack(spacing: Theme.Spacing.xxSmall) {
                Text(viewModel.greetingText)
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.primaryText)
                    .multilineTextAlignment(.center)
                
                Text(viewModel.wakeTimeMessage)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Wake Up Button - Large tap target
            Button(action: {
                HapticFeedback.success()
                viewModel.wakeUpDidSelected()
            }) {
                Text("Wake Up")
                    .font(Theme.Typography.buttonLabel)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: Theme.Sizes.buttonHeight)
                    .background(Theme.Colors.primary)
                    .cornerRadius(Theme.Sizes.cornerRadius)
            }
            .buttonStyle(PlainButtonStyle())
            .scaleEffect(isAnimating ? 1.05 : 0.95)
            .animation(
                Theme.Animation.smooth
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
        }
        .padding(Theme.Spacing.small)
        .onAppear {
            isAnimating = true
            withAnimation(Theme.Animation.smooth.repeatForever(autoreverses: false)) {
                sunRotation = 360
            }
            
            // Play wake up haptics pattern
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                HapticFeedback.success()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                HapticFeedback.success()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                HapticFeedback.success()
            }
        }
    }

}

// MARK: - PREVIEW
struct FinishedSessionView_Previews: PreviewProvider {
    static var previews: some View {
        FinishedSessionView()
    }
}
