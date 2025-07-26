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

    @AppStorage("measureState") var state: MeasureState = .noStarted

    // MARK: - Body

    var body: some View {
        switch state {
        case .noStarted:
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

// Time Picker Component - Simplified for small screens
struct SleepTimePicker: View {
    @Binding var hour: Int
    @Binding var minute: Int
    
    var body: some View {
        HStack(spacing: 2) {
            Picker("Hour", selection: $hour) {
                ForEach(0..<24) { h in
                    Text(String(format: "%02d", h))
                        .tag(h)
                }
            }
            .frame(width: 50)
            .labelsHidden()
            
            Text(":")
                .font(Theme.Typography.title)
            
            Picker("Minute", selection: $minute) {
                ForEach(0..<60) { m in
                    Text(String(format: "%02d", m))
                        .tag(m)
                }
            }
            .frame(width: 50)
            .labelsHidden()
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
    
    private let sliderWidth: CGFloat = WKInterfaceDevice.current().screenBounds.width - 40
    private let buttonSize: CGFloat = 50
    private let threshold: CGFloat = 0.8
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background
            RoundedRectangle(cornerRadius: Theme.Sizes.cornerRadius)
                .fill(Theme.Colors.sliderTrack)
                .frame(height: Theme.Sizes.sliderHeight)
            
            // Fill progress
            RoundedRectangle(cornerRadius: Theme.Sizes.cornerRadius)
                .fill(Theme.Colors.sliderFill.opacity(dragOffset / (sliderWidth - buttonSize)))
                .frame(width: dragOffset + buttonSize, height: Theme.Sizes.sliderHeight)
            
            // Instruction text
            if dragOffset < 10 {
                HStack {
                    Spacer()
                    Text("Slide to Start")
                        .font(Theme.Typography.callout)
                        .foregroundColor(Theme.Colors.secondaryText)
                    Spacer()
                }
                .transition(.opacity)
            }
            
            // Draggable button
            HStack {
                ZStack {
                    Circle()
                        .fill(Theme.Colors.primary)
                        .frame(width: buttonSize, height: buttonSize)
                    
                    Image(systemName: "moon.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                }
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
