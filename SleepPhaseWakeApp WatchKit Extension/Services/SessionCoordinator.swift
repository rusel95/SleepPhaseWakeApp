//
//  SessionCoordinator.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 18.05.2022.
//

import SwiftUI

class SessionCoordinator {

    private var session: WKExtendedRuntimeSession?

    func start() {
        guard session?.state != .running else { return }

        // create or recreate session if needed
        if nil == session || session?.state == .invalid {
            session = WKExtendedRuntimeSession()
        }
        session?.start(at: Date())
    }

    func invalidate() {
        session?.invalidate()
    }
    
}
