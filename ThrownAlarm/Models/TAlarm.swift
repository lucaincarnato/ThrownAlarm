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
import ActivityKit

@Model
class TAlarm{
    // MARK: ATTRIBUTES
    var TID: UUID = UUID()
    var alarmIDs: [Alarm.ID] = []
    var sleepTime: Alarm.Schedule.Relative.Time = Alarm.Schedule.Relative.Time(hour: 23, minute: 30)
    var wakeTime: Alarm.Schedule.Relative.Time = Alarm.Schedule.Relative.Time(hour: 8, minute: 30)
    var weekdays: [Locale.Weekday] = []
    var sound: String = "Princess"
    var rounds: Int = 3
    var active: Bool = false
    var created: Date = Date()
    
    // MARK: STATIC ATTRIBUTES
    static var sounds: [String] = [
        "Princess",
        "Celestial",
        "Enchanted",
        "Joy",
        "Mindful",
        "Penguin",
        "Plucks",
        "Stardust",
        "Sunday",
        "Valley"
    ]
    
    // MARK: INITIALIZERS
    init(sleepTime: Alarm.Schedule.Relative.Time, wakeTime: Alarm.Schedule.Relative.Time) {
        self.sleepTime = sleepTime
        self.wakeTime = wakeTime
    }
    
    init() {}
    
    // MARK: PUBLIC METHODS
    // Get the difference in minutes between the sleep and wake time (in hour and minutes)
    func getDuration() -> Int {
        let sleepMinutes = sleepTime.hour * 60 + sleepTime.minute
        let wakeMinutes = wakeTime.hour * 60 + wakeTime.minute
        // Return inverse duration (day - time determined) if the user goes to sleep before midnight
        if wakeMinutes < sleepMinutes { return 1440 - abs(wakeMinutes - sleepMinutes)}
        return abs(wakeMinutes - sleepMinutes)
    }
    
    // Schedule a notification to remind of bedtime and ten alarms
    func setAlarm() async {
        active = true
        clearAllNotifications() // Does not confuse user with many bedtime
        scheduleNotification(sleepTime)
        // Schedule ten alarms distanced by one minute
        for i in 0...9 {
            await scheduleAlarm(hour: wakeTime.hour, minute: wakeTime.minute + i)
        }
    }
    
    // Cancel all the alarms associated with the current alarm
    func cancelAlarm() {
        active = false
        do{
            for alarm in try AlarmManager.shared.alarms {
                // If the AlarmManager's alarm is in the current id array, cancel the alarm
                if alarmIDs.contains(alarm.id) {
                    try AlarmManager.shared.cancel(id: alarm.id)
                }
            }
        } catch {
            print("Cannot cancel alarms")
        }
    }
    
    // Get Time component and compose right string
    static func toString(_ text: Alarm.Schedule.Relative.Time) -> String{
        let hourString: String
        let minuteString: String
        // If hour has only one digit add 0 in front
        if text.hour < 10 { hourString = "0\(text.hour)" }
        else { hourString = "\(text.hour)" }
        // If minute has only one digit add 0 in front
        if text.minute < 10 { minuteString = "0\(text.minute)" }
        else { minuteString = "\(text.minute)" }
        // Compose string
        return "\(hourString):\(minuteString)"
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
    
    // Schedule an alarm at the next hour:minute
    private func scheduleAlarm(hour: Int, minute: Int) async {
        let alarmID = UUID()
        let time = Alarm.Schedule.Relative.Time(hour: hour, minute: minute)
        let relative = Alarm.Schedule.Relative(time: time, repeats: weekdays.isEmpty ? .never : .weekly(Array(weekdays)))
        let schedule = Alarm.Schedule.relative(relative)
        // Snooze button
        let stopButton = AlarmButton(
            text: "Snooze",
            textColor: Color.white,
            systemImageName: "battery.25percent"
        )
        // Wake up button that opens the app and starts the game
        let secondaryButton = AlarmButton(
            text: "Wake Up",
            textColor: Color.white,
            systemImageName: "basketball.fill"
        )
        // Set up the presentation for alarm
        let alertPresentation = AlarmPresentation.Alert(
            title: "Time to wake up!",
            stopButton: stopButton,
            secondaryButton: secondaryButton,
            secondaryButtonBehavior: .custom
        )
        // Get attributes for ActivityKit tools
        let attributes = AlarmAttributes<CookingData>(
            presentation: AlarmPresentation(alert: alertPresentation),
            tintColor: Color.accent,
        )
        // Secondary button custom action's intent
        let secondaryIntent = OpenInApp(alarmID: alarmID.uuidString)
        // Configure alarm for scheduling
        let alarmConfiguration = AlarmManager.AlarmConfiguration<CookingData>(
            schedule: schedule,
            attributes: attributes,
            secondaryIntent: secondaryIntent,
            sound: .named(sound + ".wav")
        )
        // Schedule alarm
        do {
            let _ = try await AlarmManager.shared.schedule(id: alarmID, configuration: alarmConfiguration)
            alarmIDs.append(alarmID)
        } catch {
            print("Cannot schedule alarm")
        }
    }
}

// Container for mock data 
extension TAlarm {
    @MainActor
    static var preview: ModelContainer {
        let container = try! ModelContainer(for: TAlarm.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        container.mainContext.insert(TAlarm())
        return container
    }
}

nonisolated
struct CookingData: AlarmMetadata{
    // Empty implementation
}
