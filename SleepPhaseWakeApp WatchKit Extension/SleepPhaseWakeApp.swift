//
//  SleepPhaseWakeApp.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 29.04.2022.
//

import SwiftUI
import OSLog

@main
struct SleepPhaseWakeApp: App {

    // MARK: - PROPERTY
    @Environment(\.scenePhase) var scenePhase

    private let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? "ruslanpopesku", category: "Lifecycle")

    // MARK: - BODY

    @SceneBuilder var body: some Scene {
        WindowGroup {
            ContentView().navigationTitle("Sleep Phase")
        }.onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                log.debug("App is in background")
            case .active:
                log.debug("App is Active")
            case .inactive:
                log.debug("App is Inactive")
            @unknown default:
                log.debug("New App state not yet introduced")
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
    
}
