//
//  OSLog+Extension.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 23.05.2022.
//

import Foundation
import os.log

extension OSLog {

    private static var subsystem = Bundle.main.bundleIdentifier!

    /// Logs the view cycles like viewDidLoad.
    static let viewCycle = OSLog(subsystem: subsystem, category: "viewcycle")

    /// Logs the SleepSessionCoordinatorService execution
    static let sessionCoordinator = OSLog(subsystem: subsystem, category: "sessionCoordinator")

}
