//
//  Constants.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 27.05.2022.
//

import Foundation
import SwiftUI
import WatchKit

struct Constants {

    static let defaultAnimationDuration: Double = 0.3
    static let defaultProcessingDuration: TimeInterval = 30 * 60 // 30 minutes
    static let defaultBackgroundColor: Color = Color("DarkTeal")

}

// MARK: - Theme

struct Theme {
    
    // MARK: - Typography (Optimized for small watch screens)
    struct Typography {
        static let largeTitle = Font.system(size: 22, weight: .bold, design: .rounded)
        static let title = Font.system(size: 20, weight: .semibold, design: .rounded)
        static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 15, weight: .regular, design: .rounded)
        static let callout = Font.system(size: 14, weight: .regular, design: .rounded)
        static let footnote = Font.system(size: 12, weight: .regular, design: .rounded)
        static let caption = Font.system(size: 11, weight: .regular, design: .rounded)
        
        // Special styles
        static let timeDisplay = Font.system(size: 36, weight: .medium, design: .rounded)
        static let buttonLabel = Font.system(size: 16, weight: .medium, design: .rounded)
    }
    
    // MARK: - Colors
    struct Colors {
        // Primary colors
        static let primary = Color("DarkTeal")
        static let primaryLight = Color("DarkTeal").opacity(0.8)
        static let primaryDark = Color("DarkTeal").opacity(1.0)
        
        // Semantic colors
        static let background = Color.black
        static let secondaryBackground = Color(white: 0.1)
        static let tertiaryBackground = Color(white: 0.15)
        
        static let primaryText = Color.white
        static let secondaryText = Color.gray
        static let tertiaryText = Color(white: 0.6)
        
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        
        // UI Element colors
        static let buttonBackground = primary
        static let buttonForeground = Color.white
        static let disabledButton = Color.gray.opacity(0.3)
        
        static let sliderTrack = Color.gray.opacity(0.3)
        static let sliderFill = primary
    }
    
    // MARK: - Spacing (Optimized for small watch screens)
    struct Spacing {
        static let xxSmall: CGFloat = 2
        static let xSmall: CGFloat = 4
        static let small: CGFloat = 6
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
        static let xLarge: CGFloat = 16
        static let xxLarge: CGFloat = 20
    }
    
    // MARK: - Sizes (Optimized for small watch screens)
    struct Sizes {
        static let buttonHeight: CGFloat = 36
        static let smallButtonHeight: CGFloat = 30
        static let iconSize: CGFloat = 20
        static let largeIconSize: CGFloat = 26
        static let sliderHeight: CGFloat = 44
        static let cornerRadius: CGFloat = 10
        static let smallCornerRadius: CGFloat = 6
    }
    
    // MARK: - Animation
    struct Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.8)
    }
}

// MARK: - Haptic Feedback Helper

struct HapticFeedback {
    static func impact(_ style: WKHapticType) {
        WKInterfaceDevice.current().play(style)
    }
    
    static func success() {
        impact(.success)
    }
    
    static func warning() {
        impact(.notification)
    }
    
    static func error() {
        impact(.failure)
    }
    
    static func selection() {
        impact(.click)
    }
}

// MARK: - View Modifiers

struct PrimaryButtonStyle: ViewModifier {
    let isEnabled: Bool
    
    func body(content: Content) -> some View {
        content
            .font(Theme.Typography.buttonLabel)
            .foregroundColor(Theme.Colors.buttonForeground)
            .frame(height: Theme.Sizes.buttonHeight)
            .frame(maxWidth: .infinity)
            .background(isEnabled ? Theme.Colors.buttonBackground : Theme.Colors.disabledButton)
            .cornerRadius(Theme.Sizes.cornerRadius)
            .scaleEffect(isEnabled ? 1.0 : 0.95)
            .animation(Theme.Animation.quick, value: isEnabled)
    }
}

struct SecondaryButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Theme.Typography.buttonLabel)
            .foregroundColor(Theme.Colors.primary)
            .frame(height: Theme.Sizes.buttonHeight)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: Theme.Sizes.cornerRadius)
                    .stroke(Theme.Colors.primary, lineWidth: 2)
            )
    }
}

struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Theme.Spacing.medium)
            .background(Theme.Colors.secondaryBackground)
            .cornerRadius(Theme.Sizes.cornerRadius)
    }
}

// MARK: - View Extensions

extension View {
    func primaryButton(isEnabled: Bool = true) -> some View {
        modifier(PrimaryButtonStyle(isEnabled: isEnabled))
    }
    
    func secondaryButton() -> some View {
        modifier(SecondaryButtonStyle())
    }
    
    func cardBackground() -> some View {
        modifier(CardBackground())
    }
    
    func standardPadding() -> some View {
        padding(Theme.Spacing.medium)
    }
    
    func withAccessibility(label: String, hint: String? = nil, traits: AccessibilityTraits = []) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(traits)
    }
}
