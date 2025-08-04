//
//  AnimationModifiers.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 04.08.2025.
//

import SwiftUI

struct PulsingAnimation: ViewModifier {
    @State private var scale: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .animation(
                Animation.easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true),
                value: scale
            )
            .onAppear {
                scale = 1.1
            }
    }
}

struct BreathingAnimation: ViewModifier {
    @State private var opacity: Double = 0.8
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .animation(
                Animation.easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true),
                value: opacity
            )
            .onAppear {
                opacity = 1.0
            }
    }
}

extension View {
    func pulsingAnimation() -> some View {
        modifier(PulsingAnimation())
    }
    
    func breathingAnimation() -> some View {
        modifier(BreathingAnimation())
    }
}