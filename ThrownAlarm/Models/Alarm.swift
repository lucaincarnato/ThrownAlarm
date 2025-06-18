//
//  Alarm.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 06/12/24.
//

import SwiftData
import Foundation
import UserNotifications

/// Model for user's alarms
@Model
class Alarm{
    // MARK: - Attributes 
    /// Unique identifier used to distinguish the minigame's deepLinks
    var identifier: String = "IdNotAvailable"
    /// Instant in which the user will go to sleep
    var sleepTime: Date = Date.now
    /// Instant in which the user wants to be woken up
    var wakeTime: Date = Date.now.addingTimeInterval(28800)
    /// Name of the desired sound with which the user wants to be woken up
    var sound: String = "Princess"
    /// Volume of the minigame
    var volume: Float = 1
    /// Number of rounds for the minigame
    var rounds: Int = 3
    /// Determines if the alarm should set off or not
    var isActive: Bool = false
    // TODO: Understand utility and Document
    var justCreated: Bool = true
    
    // MARK: - Initializers
    /// Creates a new Alarm with a random id
    init () {
        identifier = UUID().uuidString
    }
    
    // TODO: Understand utility and Document
    init (_ justCreated: Bool) {
        identifier = UUID().uuidString
        self.justCreated = justCreated
    }
    
    // MARK: - Public methods
    /// Determine the duration of the sleep set up in the alarm
    /// - Returns: Difference between the wake up time and the sleep time
    func getDuration() -> TimeInterval {
        return self.wakeTime.timeIntervalSinceReferenceDate - self.sleepTime.timeIntervalSinceReferenceDate
    }
    
    /// Enable or disable the alarm, sending or deleting the notifications according
    /// - Parameter flag: Determines if the alarm should be enabled or not
    func setAlarm(_ flag: Bool) {
        correctTime()
        isActive = flag
        if flag {
            sendNotification()
        } else {
            clearNotifications()
        }
    }
    
    /// Impede alarms that has wake up times in the past
    func correctTime() {
        if self.wakeTime <= Date.now {
            self.wakeTime = wakeTime.addingTimeInterval(86400)
        }
    }
    
    // MARK: - Private methods
    /// Send a notification at the sleep time and 10 notification at the wake up time with the alarm's id to trigger the mingame
    private func sendNotification(){
        clearNotifications()
        scheduleNotification(self.sleepTime, isAlarm: false, code: -1)
        for i in 0..<10{
            scheduleNotification(self.wakeTime.addingTimeInterval(Double(30 * i)), isAlarm: true, code: i)
        }
    }
    
    /// Schedule a notification based on the time, the use and the code for the deepLink
    /// - Parameters:
    ///   - date: Instant in which the notification should be delivered
    ///   - isAlarm: Determine if the notification should be the alarm one or the "Good night" one
    ///   - code: Additional parameter for the UNNotificationRequest's identifier to tag each notification of the same alarm (same id but different codes)
    private func scheduleNotification(_ date: Date, isAlarm: Bool, code: Int) {
        let content = UNMutableNotificationContent()
        if isAlarm {
            content.title = "It's time to wake up"
            content.body = "Wake up or you will lose the streak."
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "\(self.sound).wav"))
            content.userInfo = ["deepLink": "throwalarm://\(self.identifier)/alarm"]
        } else {
            content.title = "It's bedtime!"
            content.body = "Don't lose your \(Int(self.getDuration() / 3600)) hours and \((Int(self.getDuration()) % 3600) / 60) minutes of sleep."
            content.sound = .default
        }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date.addingTimeInterval((Date.now > date) ? 86400 : 0))
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: self.identifier + "\(code)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    /// Remove from the UNUserNotificationCenter the notifications that shares the same id, aka the alarm's one
    private func clearNotifications() {
        var identifiers: [String] = []
        identifiers.append(self.identifier + "-1")
        for i in 0..<10 {
            identifiers.append(self.identifier + "\(i)")
        }
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllDeliveredNotifications() // Clear not yet sent ones
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers) // Clear delivered ones
    }
}
