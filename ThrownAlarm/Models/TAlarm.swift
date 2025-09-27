//
//  Alarm.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 06/12/24.
//

import SwiftData
import SwiftUI
import Foundation
import UserNotifications
import AlarmKit

@Model
class TAlarm{
    // MARK: ATTRIBUTES
    var TID: UUID = UUID()
    var alarmIDs: [Alarm.ID] = []
    var sleepTime: Alarm.Schedule.Relative.Time
    var wakeTime: Alarm.Schedule.Relative.Time
    var sound: String = ""
    var rounds: Int = 3
    var active: Bool = false
    
    // MARK: INITIALIZERS
    init(sleepTime: Alarm.Schedule.Relative.Time, wakeTime: Alarm.Schedule.Relative.Time) {
        self.sleepTime = sleepTime
        self.wakeTime = wakeTime
    }
    
    // MARK: PUBLIC METHODS
    // Get the difference in minutes between the sleep and wake time (in hour and minutes)
    func getDuration() -> Int {
        let sleepMinutes = sleepTime.hour * 60 + sleepTime.minute
        let wakeMinutes = wakeTime.hour * 60 + wakeTime.minute
        return abs(wakeMinutes - sleepMinutes)
    }
    
    // Delete all previous notification (to not confuse user) and schedule a notification to remind of bedtime
    func setAlarm() async {
        clearAllNotifications()
        scheduleNotification(sleepTime)
        for i in 0...9 {
            print(i)
            await scheduleAlarm(hour: wakeTime.hour, minute: wakeTime.minute + i, "\(i)")
        }
    }
    
    func cancelAlarm() {
        do{
            for alarm in try AlarmManager.shared.alarms {
                if !alarmIDs.contains(alarm.id) { continue }
                try AlarmManager.shared.cancel(id: alarm.id)
            }
        } catch {
            print("Cannot cancel alarms")
        }
    }
    
    // MARK: PRIVATE METHODS
    // Schedule a notification for the specified date
    private func scheduleNotification(_ time: Alarm.Schedule.Relative.Time) {
        // Notification content
        let content = UNMutableNotificationContent()
        content.title = "It's bedtime!"
        content.body = "Don't lose your \(getDuration() / 60) hours and \(getDuration() % 60) minutes of sleep."
        content.sound = .default
        // Notification preparation
        let trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: time.hour, minute: time.minute), repeats: false)
        // Notification scheduling
        let request = UNNotificationRequest(identifier: TID.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // Clear all delivered and pending notification from user notification center
    private func clearAllNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllDeliveredNotifications()
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    private func scheduleAlarm(hour: Int, minute: Int, _ text: String) async {
        let alarmID = UUID()
        let weekdays: [Locale.Weekday] = []
        let time = Alarm.Schedule.Relative.Time(hour: hour, minute: minute)
        let relative = Alarm.Schedule.Relative(time: time, repeats: weekdays.isEmpty ? .never : .weekly(Array(weekdays)))
        let schedule = Alarm.Schedule.relative(relative)
        
        let stopButton = AlarmButton(
            text: "Dismiss",
            textColor: Color.white,
            systemImageName: "stop.circle"
        )
        
        let secondaryButton = AlarmButton(
            text: "Open",
            textColor: Color.white,
            systemImageName: "arrow.right.circle.fill"
        )
        
        let alertPresentation = AlarmPresentation.Alert(
            title: "Time to wake up bitch \(text)",
            stopButton: stopButton,
            secondaryButton: secondaryButton,
            secondaryButtonBehavior: .custom
        )
        
        let attributes = AlarmAttributes<CookingData>(
            presentation: AlarmPresentation(alert: alertPresentation),
            tintColor: Color.green,
        )
        
        let secondaryIntent = OpenInApp(alarmID: alarmID.uuidString)
        
        // let sound = AlertConfiguration.AlertSound.named("Chime")
        
        let alarmConfiguration = AlarmManager.AlarmConfiguration<CookingData>(
            schedule: schedule,
            attributes: attributes,
            secondaryIntent: secondaryIntent
            // sound: sound
        )
        
        do {
            let _ = try await AlarmManager.shared.schedule(id: alarmID, configuration: alarmConfiguration)
            alarmIDs.append(alarmID)
        } catch {
            print("Mammt")
        }
    }
}

nonisolated
struct CookingData: AlarmMetadata{
    // Empty implementation
}
