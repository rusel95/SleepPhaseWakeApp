//
//  ContentView.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 29.04.2022.
//

import Foundation
import SwiftUI
import WatchKit

struct ContentView: View {

    // MARK: - Property

    @StateObject private var stateManager = AppStateManager.shared

    // MARK: - Body

    var body: some View {
        switch stateManager.measureState {
        case .notStarted:
            NotStartedSessionView()
        case .started:
            StartedSessionView()
        case .finished:
            FinishedSessionView()
        }
    }

}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        ContentView()
    }

}

// MARK: - UI Components

// Time Picker Component - Adaptive for all screen sizes
struct SleepTimePicker: View {
    @Binding var hour: Int
    @Binding var minute: Int
    
    private var pickerWidth: CGFloat {
        AdaptiveSize(small: 45, medium: 50, large: 55).value
    }
    
    private var pickerHeight: CGFloat {
        AdaptiveSize(small: 60, medium: 70, large: 80).value
    }
    
    var body: some View {
        HStack(spacing: 2) {
            Picker("Hour", selection: $hour) {
                ForEach(0..<24) { h in
                    Text(String(format: "%02d", h))
                        .tag(h)
                }
            }
            .frame(width: pickerWidth, height: pickerHeight)
            .labelsHidden()
            .clipped()
            
            Text(":")
                .font(Theme.Adaptive.Typography.title)
            
            Picker("Minute", selection: $minute) {
                ForEach(0..<60) { m in
                    Text(String(format: "%02d", m))
                        .tag(m)
                }
            }
            .frame(width: pickerWidth, height: pickerHeight)
            .labelsHidden()
            .clipped()
        }
    }
}

// Progress Ring
struct ProgressRing: View {
    let progress: Double
    var lineWidth: CGFloat = 4
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(
                    Theme.Colors.sliderTrack,
                    lineWidth: lineWidth
                )
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Theme.Colors.primary,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(Theme.Animation.smooth, value: progress)
        }
    }
}

// Slide to Start Component
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
    private let threshold: CGFloat = 0.8
    
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
                            if newOffset > (sliderWidth - buttonSize) * 0.5 && !isActivated {
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
