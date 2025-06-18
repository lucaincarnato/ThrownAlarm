//
//  Alarm.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 06/12/24.
//

import SwiftData
import Foundation
import UserNotifications

@Model
class Alarm{
    var identifier: String = "IdNotAvailable"
    var sleepTime: Date = Date.now
    var wakeTime: Date = Date.now.addingTimeInterval(28800)
    var sound: String = "Princess"
    var volume: Float = 1
    var rounds: Int = 3
    var isActive: Bool = false
    var justCreated: Bool = true
    
    init () {
        identifier = UUID().uuidString
    }
    
    init (_ justCreated: Bool) {
        identifier = UUID().uuidString
        self.justCreated = justCreated
    }
    
    func copy(alarm: Alarm){
        self.sleepTime = alarm.sleepTime
        self.wakeTime = alarm.wakeTime
        self.sound = alarm.sound
        self.volume = alarm.volume
        self.rounds = alarm.rounds
    }
    
    func export(alarm: Alarm){
        alarm.sleepTime = self.sleepTime
        alarm.wakeTime = self.wakeTime
        alarm.sound = self.sound
        alarm.volume = self.volume
        alarm.rounds = self.rounds
    }
    
    func getDuration() -> TimeInterval {
        return self.wakeTime.timeIntervalSinceReferenceDate - self.sleepTime.timeIntervalSinceReferenceDate
    }
    
    func setAlarm(_ flag: Bool) {
        correctTime()
        isActive = flag
        if flag {
            sendNotification()
        } else {
            clearNotifications()
        }
    }
    
    func correctTime() {
        if self.wakeTime <= Date.now {
            self.wakeTime = wakeTime.addingTimeInterval(86400)
        }
    }
    
    private func sendNotification(){
        clearNotifications()
        scheduleNotification(self.sleepTime, isAlarm: false, code: -1)
        for i in 0..<10{
            scheduleNotification(self.wakeTime.addingTimeInterval(Double(30 * i)), isAlarm: true, code: i)
        }
    }
    
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
