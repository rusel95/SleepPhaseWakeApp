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
        VStack(spacing: Theme.Adaptive.Spacing.medium) {
            Spacer()
            
            // Simple sun icon
            Image(systemName: "sun.max.fill")
                .symbolRenderingMode(.multicolor)
                .font(.system(size: AdaptiveSize(small: 35, medium: 40, large: 45).value))
                .scaleEffect(isAnimating ? 1.1 : 0.9)
                .animation(
                    Theme.Animation.smooth
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            // Greeting
            VStack(spacing: 2) {
                Text(viewModel.greetingText)
                    .font(Theme.Adaptive.Typography.headline)
                    .foregroundColor(Theme.Colors.primaryText)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                
                Text(viewModel.wakeTimeMessage)
                    .font(Theme.Adaptive.Typography.body)
                    .foregroundColor(Theme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Wake Up Button - Large tap target
            Button(action: {
                HapticFeedback.success()
                viewModel.wakeUpDidSelected()
            }) {
                Text("Wake Up")
                    .font(Theme.Adaptive.Typography.body)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: Theme.Adaptive.Sizes.buttonHeight)
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
        .adaptivePadding()
        .onAppear {
            isAnimating = true
            withAnimation(Theme.Animation.smooth.repeatForever(autoreverses: false)) {
                sunRotation = 360
            }
            
            // Play wake up haptics pattern
            for delay in AppConfiguration.Haptics.wakeUpPatternDelays {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    HapticFeedback.success()
                }
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
