//
//  SleepPhaseWakeApp.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 29.04.2022.
//

import SwiftUI

@main
struct SleepPhaseWakeApp: App {

    @Environment(\.scenePhase) var scenePhase

    @SceneBuilder var body: some Scene {
        WindowGroup {
            ContentView().navigationTitle("Sleep Phase")
        }.onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                print("App is in background")
            case .active:
                print("App is Active")
            case .inactive:
                print("App is Inactive")
            @unknown default:
                print("New App state not yet introduced")
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
    
}
