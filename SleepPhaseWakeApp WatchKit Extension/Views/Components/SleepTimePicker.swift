//
//  SleepTimePicker.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 04.08.2025.
//

import SwiftUI

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
                    Text(String(format: AppConfiguration.TimeFormat.hourPattern, h))
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
                    Text(String(format: AppConfiguration.TimeFormat.minutePattern, m))
                        .tag(m)
                }
            }
            .frame(width: pickerWidth, height: pickerHeight)
            .labelsHidden()
            .clipped()
        }
    }
}