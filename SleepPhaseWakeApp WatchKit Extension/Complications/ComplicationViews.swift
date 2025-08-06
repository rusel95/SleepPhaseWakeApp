//
//  ComplicationViews.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 04.08.2025.
//

import SwiftUI
import ClockKit

struct ComplicationViews {
    
    // MARK: - Graphic Corner View
    struct GraphicCornerView: View {
        let info: SleepComplicationInfo
        
        var body: some View {
            ZStack {
                Circle()
                    .fill(info.isActive ? Color.green.opacity(0.3) : Color.gray.opacity(0.3))
                
                Icons.Sleep.getImage(isActive: info.isActive)
                    .font(.system(size: 22))
                    .foregroundColor(info.isActive ? .green : .white)
            }
        }
    }
    
    // MARK: - Graphic Circular View
    struct GraphicCircularView: View {
        let info: SleepComplicationInfo
        
        var body: some View {
            ZStack {
                Circle()
                    .stroke(lineWidth: 3)
                    .foregroundColor(.gray.opacity(0.3))
                
                if info.isActive {
                    Circle()
                        .trim(from: 0, to: progressValue)
                        .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .foregroundColor(.green)
                        .rotationEffect(.degrees(-90))
                }
                
                VStack(spacing: 2) {
                    Icons.Sleep.getImage(isActive: info.isActive)
                        .font(.system(size: 16))
                        .foregroundColor(info.isActive ? .green : .white)
                    
                    Text(info.timeText)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        
        private var progressValue: Double {
            guard info.isActive else { return 0 }
            let now = Date()
            let processingDuration: TimeInterval = 1800 // 30 minutes
            let minimumWakeUpDate = info.wakeUpTime.addingTimeInterval(-processingDuration)
            
            if now >= info.wakeUpTime {
                return 1.0
            } else if now <= minimumWakeUpDate {
                return 0.0
            } else {
                return now.timeIntervalSince(minimumWakeUpDate) / processingDuration
            }
        }
    }
    
    // MARK: - Graphic Rectangular View
    struct GraphicRectangularView: View {
        let info: SleepComplicationInfo
        
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Icons.Sleep.getImage(isActive: info.isActive)
                        .font(.system(size: 20))
                        .foregroundColor(info.isActive ? .green : .white)
                    
                    Text("Sleep Phase")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                Text(info.statusText)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "alarm")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    
                    Text(info.timeText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                }
            }
            .padding(4)
        }
    }
    
    // MARK: - Graphic Extra Large View
    struct GraphicExtraLargeView: View {
        let info: SleepComplicationInfo
        
        var body: some View {
            ZStack {
                Circle()
                    .fill(info.isActive ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                
                VStack(spacing: 8) {
                    Icons.Sleep.getImage(isActive: info.isActive)
                        .font(.system(size: 44))
                        .foregroundColor(info.isActive ? .green : .white)
                    
                    Text(info.statusText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(info.timeText)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}