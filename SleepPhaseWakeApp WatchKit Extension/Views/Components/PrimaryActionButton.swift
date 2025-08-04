//
//  PrimaryActionButton.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 04.08.2025.
//

import SwiftUI

struct PrimaryActionButton: View {
    let title: String
    let systemImage: String?
    let action: () -> Void
    let useSuccessHaptic: Bool
    
    init(title: String, systemImage: String? = nil, useSuccessHaptic: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.useSuccessHaptic = useSuccessHaptic
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            if useSuccessHaptic {
                HapticFeedback.success()
            } else {
                HapticFeedback.selection()
            }
            action()
        }) {
            HStack {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
            .frame(maxWidth: .infinity)
        }
        .primaryButton()
    }
}

struct DestructiveActionButton: View {
    let title: String
    let systemImage: String?
    let action: () -> Void
    
    init(title: String, systemImage: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            HapticFeedback.warning()
            action()
        }) {
            HStack {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
            .frame(maxWidth: .infinity)
        }
        .secondaryButton()
        .foregroundColor(.red)
    }
}