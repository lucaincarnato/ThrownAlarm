//
//  Alarm.swift
//  AmericanoChallenge
//
//  Created by Luca Maria Incarnato on 06/12/24.
//

import SwiftData
import Foundation
import UserNotifications

@Model
class Alarm{
    var sleepTime: Date = Date.now
    var wakeTime: Date = Date.now.addingTimeInterval(28800) // Sets the wake time 8h from the sleeps as default
    var sleepDuration: TimeInterval = 28800
    var ringsIn: TimeInterval = 28800 // Let the user know when the alarm will ring
    var sound: String = "Princess"
    var rounds: Int = 3
    
    // Initializer for
    init () {
        // Compiler needs all properties to be initialized before calling method
        self.sleepDuration = 0
        self.setDuration()
    }
    
    // Sets the time interval as the difference between the time the user wakes up and the one when it goes to sleep
    func setDuration(){
        // If default values are kept, it should set sleepDuration to 86400
        self.sleepDuration = self.wakeTime.timeIntervalSinceReferenceDate - self.sleepTime.timeIntervalSinceReferenceDate
        self.ringsIn = Date.now.distance(to: self.wakeTime) // Determine the difference between the wakeTime and now
    }
    
    // Allow the user to change the time of go to sleep and wake up, updating the duration
    func setAlarm(_ sleepTime: Date, _ wakeTime: Date){
        // Doesn't allow the user to set the alarm for a date before the go to sleep one
        if(sleepTime > wakeTime) {
            self.wakeTime = wakeTime.addingTimeInterval(86400)
        }
        self.sleepTime = sleepTime
        self.wakeTime = wakeTime
        setDuration() // Automatically determine the sleep duration
    }
    
    // Send a notification each 30 seconds for a total of 10 times
    func sendNotification(){
        requestNotificationPermission() // Request permission to send notification
        clearAllNotifications() // Clear notification center
        // configureNotificationCategories() // Configure the type of notification as critical
        // Send the 10 notifications
        for i in 0..<10{
            scheduleNotification(for: self.wakeTime.addingTimeInterval(Double(30 * i)))
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
    private func scheduleNotification(for date: Date) {
        let content = UNMutableNotificationContent()
        // Sets up notification information
        content.title = "It's time to wake up"
        content.body = "Wake up or you will lose the streak."
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "\(self.sound).wav"))
        // Get component from Date in order to schedule for a specific time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        // Create the trigger based on date components
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        // Create a unique request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        // Adds request to notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error while scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification successfully scheduled for \(date).")
            }
        }
    }

    // Clear the notification center from all the notification
    func clearAllNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests() // Clear not yet sent ones
        notificationCenter.removeAllDeliveredNotifications() // Clear delivered ones
    }
    
    // Configure notification's category, in order to send them as critical
    private func configureNotificationCategories() {
        let category = UNNotificationCategory(
            identifier: "critical",
            actions: [],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}
