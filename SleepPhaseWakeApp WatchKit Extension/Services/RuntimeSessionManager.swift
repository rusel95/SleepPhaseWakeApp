//
//  RuntimeSessionManager.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 04.08.2025.
//

import Foundation
import WatchKit
import OSLog

protocol RuntimeSessionManaging {
    var isRunning: Bool { get }
    func start(at date: Date, delegate: WKExtendedRuntimeSessionDelegate)
    func stop()
    func notifyUser(hapticType: WKHapticType)
}

final class RuntimeSessionManager: RuntimeSessionManaging {
    private var session: WKExtendedRuntimeSession?
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "RuntimeSessionManager")
    
    var isRunning: Bool {
        session?.state == .running
    }
    
    func start(at date: Date, delegate: WKExtendedRuntimeSessionDelegate) {
        guard session?.state != .running else { return }
        
        if session == nil || session?.state == .invalid {
            session = WKExtendedRuntimeSession()
        }
        
        session?.delegate = delegate
        session?.start(at: date)
        
        logger.info("Runtime session scheduled to start at \(date)")
    }
    
    func stop() {
        session?.delegate = nil
        session?.invalidate()
        session = nil
        
        logger.info("Runtime session stopped")
    }
    
    func notifyUser(hapticType: WKHapticType) {
        session?.notifyUser(hapticType: hapticType)
    }
}