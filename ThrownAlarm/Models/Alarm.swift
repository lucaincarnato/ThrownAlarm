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
    var id: String = "IdNotAvailable"
    var sleepTime: Date = Date.now
    var wakeTime: Date = Date.now.addingTimeInterval(28800)
    var sleepDuration: TimeInterval = 28800
    var sound: String = "Princess"
    var rounds: Int = 3
    var isActive: Bool = false
    var justCreated: Bool = true
    
    init () {
        id = UUID().uuidString
        self.sleepDuration = 0
        self.setDuration()
    }
    
    init (_ justCreated: Bool) {
        id = UUID().uuidString
        self.justCreated = justCreated
        self.sleepDuration = 0
        self.setDuration()
    }
    
    func copy(alarm: Alarm){
        self.sleepTime = alarm.sleepTime
        self.wakeTime = alarm.wakeTime
        self.setDuration()
        self.sound = alarm.sound
        self.rounds = alarm.rounds
    }
    
    func export(alarm: Alarm){
        alarm.sleepTime = self.sleepTime
        alarm.wakeTime = self.wakeTime
        alarm.setDuration()
        alarm.sound = self.sound
        alarm.rounds = self.rounds
    }
    
    func setDuration(){
        self.sleepDuration = self.wakeTime.timeIntervalSinceReferenceDate - self.sleepTime.timeIntervalSinceReferenceDate
    }
    
    func setAlarm(){
        if self.wakeTime <= Date.now {
            self.wakeTime = wakeTime.addingTimeInterval(86400)
        }
    }
    
    func sendNotification(){
        clearAllNotifications()
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
            content.userInfo = ["deepLink": "throwalarm://\(self.id)/alarm"]
        } else {
            content.title = "It's bedtime!"
            content.body = "Don't lose your \(Int(self.sleepDuration / 3600)) hours and \((Int(self.sleepDuration) % 3600) / 60) minutes of sleep."
            content.sound = .default
        }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date.addingTimeInterval((Date.now > date) ? 86400 : 0))
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: self.id + "\(code)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func clearAllNotifications() {
        var identifiers: [String] = []
        identifiers.append(self.id + "-1")
        for i in 0..<10 {
            identifiers.append(self.id + "\(i)")
        }
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllDeliveredNotifications() // Clear not yet sent ones
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers) // Clear delivered ones
    }
}
