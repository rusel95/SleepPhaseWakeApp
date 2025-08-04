//
//  UserNotificationService.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 04.08.2025.
//

import Foundation
import UserNotifications

protocol NotificationService {
    func requestAuthorization(completion: @escaping (Bool) -> Void)
    func scheduleWakeUpNotification(title: String, body: String, sound: UNNotificationSound?)
    func removeAllPendingNotifications()
}

final class UserNotificationService: NotificationService {
    private let notificationCenter = UNUserNotificationCenter.current()
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func scheduleWakeUpNotification(title: String, body: String, sound: UNNotificationSound?) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = sound
        content.categoryIdentifier = "WAKE_UP"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "wakeUp", content: content, trigger: trigger)
        
        notificationCenter.add(request)
    }
    
    func removeAllPendingNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
}