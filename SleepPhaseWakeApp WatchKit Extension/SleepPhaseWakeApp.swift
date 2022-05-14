//
//  SleepPhaseWakeApp.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 29.04.2022.
//

import SwiftUI

@main
struct SleepPhaseWakeApp: App {

    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
    
}
