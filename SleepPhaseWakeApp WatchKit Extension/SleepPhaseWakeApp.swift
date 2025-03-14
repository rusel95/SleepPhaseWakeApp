//
//  SleepPhaseWakeApp.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 29.04.2022.
//

import SwiftUI
import OSLog
import Sentry

@main
struct SleepPhaseWakeApp: App {

    // MARK: - PROPERTY
    @Environment(\.scenePhase) var scenePhase

    private let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? "ruslanpopesku", category: "Lifecycle")

    // MARK: - INIT
    init() {
        SentrySDK.start { options in
            options.dsn = "https://fb83f8425ca7481d9308ed42dbf46b01@o1271632.ingest.sentry.io/6464194"
            options.debug = true // Enabled debug when first installing is always helpful
            // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
            // We recommend adjusting this value in production.
            options.tracesSampleRate = 1.0
        }
    }
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
    }
    
}
