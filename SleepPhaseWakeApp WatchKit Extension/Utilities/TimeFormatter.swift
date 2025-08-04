//
//  TimeFormatter.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 04.08.2025.
//

import Foundation

enum TimeFormatter {
    static let timeOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
    
    static let countdownFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    static func formatTime(_ date: Date) -> String {
        timeOnlyFormatter.string(from: date)
    }
    
    static func formatCountdown(from startDate: Date, to endDate: Date) -> String {
        let timeInterval = endDate.timeIntervalSince(startDate)
        return countdownFormatter.string(from: timeInterval) ?? "00:00:00"
    }
    
    static func formatDuration(_ timeInterval: TimeInterval) -> String {
        countdownFormatter.string(from: timeInterval) ?? "00:00:00"
    }
}