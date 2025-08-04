//
//  DeviceSize.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 04.08.2025.
//

import SwiftUI
import WatchKit

// MARK: - Device Size Detection

enum WatchSize {
    case small      // 38mm, 40mm, 41mm
    case medium     // 42mm, 44mm, 45mm
    case large      // 49mm Ultra
    
    static var current: WatchSize {
        let screenWidth = WKInterfaceDevice.current().screenBounds.width
        
        // Determine size based on screen width
        switch screenWidth {
        case 0..<170:  // 38mm (136) and 40mm/41mm (162)
            return .small
        case 170..<190: // 42mm (176) and 44mm/45mm (184)
            return .medium
        default:        // 49mm Ultra (205)
            return .large
        }
    }
    
    var scaleFactor: CGFloat {
        switch self {
        case .small: return 0.85
        case .medium: return 1.0
        case .large: return 1.15
        }
    }
}

// MARK: - Adaptive Sizing

struct AdaptiveSize {
    let small: CGFloat
    let medium: CGFloat
    let large: CGFloat
    
    var value: CGFloat {
        switch WatchSize.current {
        case .small: return small
        case .medium: return medium
        case .large: return large
        }
    }
    
    static func scaled(_ baseValue: CGFloat) -> CGFloat {
        return baseValue * WatchSize.current.scaleFactor
    }
}

// MARK: - Adaptive Theme

extension Theme {
    struct Adaptive {
        // Typography
        struct Typography {
            static let largeTitle = Font.system(
                size: AdaptiveSize(small: 20, medium: 22, large: 24).value,
                weight: .bold,
                design: .rounded
            )
            
            static let title = Font.system(
                size: AdaptiveSize(small: 18, medium: 20, large: 22).value,
                weight: .semibold,
                design: .rounded
            )
            
            static let headline = Font.system(
                size: AdaptiveSize(small: 15, medium: 17, large: 19).value,
                weight: .semibold,
                design: .rounded
            )
            
            static let body = Font.system(
                size: AdaptiveSize(small: 13, medium: 15, large: 17).value,
                weight: .regular,
                design: .rounded
            )
            
            static let timeDisplay = Font.system(
                size: AdaptiveSize(small: 30, medium: 36, large: 42).value,
                weight: .medium,
                design: .rounded
            )
        }
        
        // Spacing
        struct Spacing {
            static let small = AdaptiveSize(small: 4, medium: 6, large: 8).value
            static let medium = AdaptiveSize(small: 6, medium: 8, large: 10).value
            static let large = AdaptiveSize(small: 10, medium: 12, large: 14).value
            static let xLarge = AdaptiveSize(small: 14, medium: 16, large: 18).value
        }
        
        // Sizes
        struct Sizes {
            static let buttonHeight = AdaptiveSize(small: 32, medium: 36, large: 40).value
            static let sliderHeight = AdaptiveSize(small: 40, medium: 44, large: 48).value
            static let iconSize = AdaptiveSize(small: 18, medium: 20, large: 22).value
            static let largeIconSize = AdaptiveSize(small: 24, medium: 26, large: 28).value
        }
    }
}

// MARK: - View Extensions

extension View {
    func adaptivePadding(_ edges: Edge.Set = .all) -> some View {
        self.padding(edges, Theme.Adaptive.Spacing.medium)
    }
    
    func adaptiveFrame(height: CGFloat? = nil) -> some View {
        self.frame(height: height.map { AdaptiveSize.scaled($0) })
    }
}