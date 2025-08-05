//
//  AppConfiguration.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 04.08.2025.
//

import Foundation

enum AppConfiguration {
    
    // MARK: - Sleep Tracking
    enum SleepTracking {
        /// Default wake window duration (30 minutes)
        static let defaultWakeWindowDuration: TimeInterval = 30 * 60
        
        /// Simulation mode wake window duration (30 seconds)
        static let simulationWakeWindowDuration: TimeInterval = 30
        
        /// Movement detection threshold for wake-up
        static let movementThreshold: Double = 1.2
        
        /// Data processing interval (1 second)
        static let dataProcessingInterval: TimeInterval = 1.0
        
        /// Accelerometer data query lookback time (5 seconds)
        static let accelerometerLookbackTime: TimeInterval = 5.0
    }
    
    // MARK: - Battery
    enum Battery {
        /// Minimum battery level for sleep tracking (20%)
        static let minimumLevel: Float = 0.2
    }
    
    // MARK: - Background Session
    enum BackgroundSession {
        /// Session timeout interval (4 hours)
        static let timeoutInterval: TimeInterval = 4 * 60 * 60
    }
    
    // MARK: - Haptic Feedback
    enum Haptics {
        /// Wake-up haptic pattern delays
        static let wakeUpPatternDelays: [TimeInterval] = [0.5, 0.7, 0.9]
    }
    
    // MARK: - UI
    enum UI {
        /// Slider activation threshold (80% of total distance)
        static let sliderActivationThreshold: CGFloat = 0.8
        
        /// Slider haptic feedback threshold (50% of total distance)
        static let sliderHapticThreshold: CGFloat = 0.5
    }
    
    // MARK: - Time Formatting
    enum TimeFormat {
        /// Hour and minute format for time display
        static let hourMinuteFormat = "HH:mm"
        
        /// Hour format string pattern
        static let hourPattern = "%02d"
        
        /// Minute format string pattern
        static let minutePattern = "%02d"
    }
}