//
//  NotificationManager.swift
//  NowFocus
//
//  Created by Tomofumi Kimura on 2025/11/20.
//

import Foundation
import UserNotifications

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isPermissionGranted: Bool = false
    
    override private init() {
        super.init()
        checkPermissionStatus()
    }
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.isPermissionGranted = granted
                completion(granted)
            }
        }
    }
    
    func checkPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isPermissionGranted = (settings.authorizationStatus == .authorized)
            }
        }
    }
    
    func scheduleNotifications(at date: Date, on days: [Int], title: String = "集中する時間です", body: String = "1分だけ集中してみませんか？") {
        // Cancel existing notifications first
        cancelNotifications()
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        for day in days {
            // Convert View ID (1=Mon, ..., 7=Sun) to Calendar Weekday (1=Sun, 2=Mon, ..., 7=Sat)
            // View: 1(Mon) -> Cal: 2
            // View: 7(Sun) -> Cal: 1
            var weekday = day + 1
            if weekday > 7 { weekday = 1 }
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            
            var components = DateComponents()
            components.hour = hour
            components.minute = minute
            components.weekday = weekday
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: "reminder_weekday_\(weekday)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification for weekday \(weekday): \(error)")
                }
            }
        }
    }
    
    func cancelNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
