//
//  ProgressRing.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 04.08.2025.
//

import SwiftUI

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