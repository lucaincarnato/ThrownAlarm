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
// Describes the alarm user needs to wake up
class Alarm{
    // Alarm information
    var sleepTime: Date = Date.now
    var wakeTime: Date = Date.now.addingTimeInterval(28800) // Sets the wake time 8h from the sleeps as default
    var sleepDuration: TimeInterval = 28800
    var sound: String = "Princess" // String name before wav/m4a extention
    var rounds: Int = 3 // Number of rounds for the minigame
    var isActive: Bool = false // Determines if the user needs to be woke up by the alarm
    var justCreated: Bool = true // Enables the modal once the alarm is created
    
    // Initializer for common adding
    init () {
        self.sleepDuration = 0
        self.setDuration()
    }
    
    // Initializer for first alarm, that doesn't need to be inizialized with modal active
    init (_ justCreated: Bool) {
        self.justCreated = justCreated
        self.sleepDuration = 0
        self.setDuration()
    }
    
    // Copy in this object the value from another object
    func copy(alarm: Alarm){
        self.sleepTime = alarm.sleepTime
        self.wakeTime = alarm.wakeTime
        self.sleepDuration = alarm.sleepDuration
        self.sound = alarm.sound
        self.rounds = alarm.rounds
    }
    
    // Copy in another object what's inside this
    func export(alarm: Alarm){
        alarm.sleepTime = self.sleepTime
        alarm.wakeTime = self.wakeTime
        alarm.sleepDuration = self.sleepDuration
        alarm.sound = self.sound
        alarm.rounds = self.rounds
    }
    
    // Sets the time interval as the difference between the time the user wakes up and the one when it goes to sleep
    func setDuration(){
        // If default values are kept, it should set sleepDuration to 86400
        self.sleepDuration = self.wakeTime.timeIntervalSinceReferenceDate - self.sleepTime.timeIntervalSinceReferenceDate
    }
    
    // Checks for alarms in the past and correct it
    func setAlarm(){
        if self.wakeTime <= Date.now {
            self.wakeTime = wakeTime.addingTimeInterval(86400)
        }
    }
    
    // Send a notification each 30 seconds for a total of 10 times
    func sendNotification(){
        requestNotificationPermission() // Request permission to send notification
        clearAllNotifications() // Clear notification center
        // configureNotificationCategories() // Configure the type of notification as critical
        scheduleNotification(self.sleepTime, isAlarm: false)
        // Send the 10 notifications
        for i in 0..<10{
            scheduleNotification(self.wakeTime.addingTimeInterval(Double(30 * i)), isAlarm: true)
        }
    }
    
    // Request the user the permission to be sent notification
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error while asking permission: \(error.localizedDescription)")
            }
            print("Permission granted: \(granted)")
        }
    }
    
    // Schedule the notification for a specific date and with a custom sound
    private func scheduleNotification(_ date: Date, isAlarm: Bool) {
        let content = UNMutableNotificationContent()
        // Differentiate the notification based on the fact that it is for the wake up or the bedtime reminder
        if isAlarm {
            // Sets up notification information for the wake up
            content.title = "It's time to wake up"
            content.body = "Wake up or you will lose the streak."
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "\(self.sound).wav"))
            content.userInfo = ["deepLink": "throwalarm://alarm"] // Deep link for the minigame only in alarm notification
        } else {
            // Sets up notification information for the bedtime
            content.title = "It's bedtime!"
            content.body = "Don't lose your \(Int(self.sleepDuration / 3600)) hours and \((Int(self.sleepDuration) % 3600) / 60) minutes of sleep."
            content.sound = .default
        }
        // Get component from Date in order to schedule for a specific time
        let calendar = Calendar.current
        // Go to next day if the date is on the past
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date.addingTimeInterval((Date.now > date) ? 86400 : 0))
        // Create the trigger based on date components
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        // Create a unique request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        // Adds request to notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error while scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification successfully scheduled for \(date.addingTimeInterval((Date.now > date) ? 86400 : 0)).")
            }
        }
    }

    // Clear the notification center from all the notification
    func clearAllNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests() // Clear not yet sent ones
        notificationCenter.removeAllDeliveredNotifications() // Clear delivered ones
    }
}
