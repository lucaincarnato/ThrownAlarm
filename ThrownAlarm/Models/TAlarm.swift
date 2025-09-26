//
//  Alarm.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 06/12/24.
//

import SwiftData
import Foundation
import UserNotifications
import AlarmKit

@Model
class TAlarm{
    // MARK: ATTRIBUTES
    var id: UUID = UUID()
    var sleepTime: Alarm.Schedule.Relative.Time
    var wakeTime: Alarm.Schedule.Relative.Time
    var duration: Int = 0
    var sound: String = ""
    var rounds: Int = 3
    var active: Bool = false
    
    // MARK: INITIALIZERS
    init(sleepTime: Alarm.Schedule.Relative.Time, wakeTime: Alarm.Schedule.Relative.Time) {
        self.sleepTime = sleepTime
        self.wakeTime = wakeTime
        setDuration()
    }
    
    // MARK: PUBLIC METHODS
    // Get the difference in minutes between the sleep and wake time (in hour and minutes)
    func setDuration(){
        let sleepMinutes = sleepTime.hour * 60 + sleepTime.minute
        let wakeMinutes = wakeTime.hour * 60 + wakeTime.minute
        duration = abs(wakeMinutes - sleepMinutes)
    }
    
    // Delete all previous notification (to not confuse user) and schedule a notification to remind of bedtime
    func sendNotification(){
        clearAllNotifications()
        scheduleNotification(sleepTime)
    }
    
    // MARK: PRIVATE METHODS
    // Schedule a notification for the specified date
    private func scheduleNotification(_ time: Alarm.Schedule.Relative.Time) {
        // Notification content
        let content = UNMutableNotificationContent()
        content.title = "It's bedtime!"
        content.body = "Don't lose your \(duration / 60) hours and \(duration % 60) minutes of sleep."
        content.sound = .default
        // Notification preparation
        let trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: time.hour, minute: time.minute), repeats: false)
        // Notification scheduling
        let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // Clear all delivered and pending notification from user notification center
    private func clearAllNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllDeliveredNotifications()
        notificationCenter.removeAllPendingNotificationRequests()
    }
}
