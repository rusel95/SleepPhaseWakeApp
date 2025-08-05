//
//  SlideToStartButton.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 04.08.2025.
//

import SwiftUI
import WatchKit

struct SlideToStartButton: View {
    @Binding var isActivated: Bool
    var onActivate: () -> Void
    
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    
    private var sliderWidth: CGFloat {
        WKInterfaceDevice.current().screenBounds.width - AdaptiveSize(small: 30, medium: 40, large: 50).value
    }
    private var buttonSize: CGFloat {
        AdaptiveSize(small: 44, medium: 50, large: 56).value
    }
    private let threshold: CGFloat = AppConfiguration.UI.sliderActivationThreshold
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background
            RoundedRectangle(cornerRadius: Theme.Sizes.cornerRadius)
                .fill(Theme.Colors.sliderTrack)
                .frame(height: Theme.Adaptive.Sizes.sliderHeight)
            
            // Fill progress
            RoundedRectangle(cornerRadius: Theme.Sizes.cornerRadius)
                .fill(Theme.Colors.sliderFill.opacity(dragOffset / (sliderWidth - buttonSize)))
                .frame(width: dragOffset + buttonSize, height: Theme.Adaptive.Sizes.sliderHeight)
            
            // Instruction text
            if dragOffset < 10 {
                HStack {
                    Spacer()
                    Text("Slide to Start")
                        .font(Theme.Adaptive.Typography.body)
                        .foregroundColor(Theme.Colors.secondaryText)
                        .minimumScaleFactor(0.8)
                    Spacer()
                }
                .transition(.opacity)
            }
            
            // Draggable button
            HStack {
                Image(systemName: "chevron.right")
                    .font(.system(size: AdaptiveSize(small: 20, medium: 24, large: 28).value, weight: .semibold))
                    .foregroundColor(Theme.Colors.primary)
                    .frame(width: buttonSize, height: buttonSize)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.2))
                    )
                    .offset(x: dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDragging = true
                                let newOffset = max(0, min(value.translation.width, sliderWidth - buttonSize))
                                dragOffset = newOffset
                                
                                // Haptic feedback at certain points
                                if newOffset > (sliderWidth - buttonSize) * AppConfiguration.UI.sliderHapticThreshold && !isActivated {
                                    HapticFeedback.selection()
                                }
                            }
                            .onEnded { value in
                                isDragging = false
                                if dragOffset > (sliderWidth - buttonSize) * threshold {
                                    // Activate
                                    withAnimation(Theme.Animation.spring) {
                                        dragOffset = sliderWidth - buttonSize
                                    }
                                    HapticFeedback.success()
                                    isActivated = true
                                    onActivate()
                                } else {
                                    // Reset
                                    withAnimation(Theme.Animation.spring) {
                                        dragOffset = 0
                                    }
                                }
                            }
                    )
                
                Spacer()
            }
        }
        .withAccessibility(
            label: "Slide to start sleep tracking",
            hint: "Double tap and swipe right to activate",
            traits: .isButton
        )
    }
}