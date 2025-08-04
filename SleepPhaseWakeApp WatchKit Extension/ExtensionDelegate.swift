//
//  ExtensionDelegate.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 04.08.2025.
//

import WatchKit
import ClockKit

class ExtensionDelegate: NSObject, WKApplicationDelegate {
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
    }
    
    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive.
        // Update complications if needed
        reloadActiveComplications()
    }
    
    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state.
        // Update complications before becoming inactive
        reloadActiveComplications()
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Handle background tasks
        for task in backgroundTasks {
            switch task {
            case let complicationTask as WKApplicationRefreshBackgroundTask:
                // Update complication data
                reloadActiveComplications()
                complicationTask.setTaskCompletedWithSnapshot(false)
            default:
                // For all other tasks, set them as completed
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
    
    private func reloadActiveComplications() {
        let server = CLKComplicationServer.sharedInstance()
        for complication in server.activeComplications ?? [] {
            server.reloadTimeline(for: complication)
        }
    }
}