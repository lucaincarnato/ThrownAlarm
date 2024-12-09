//
//  Profile.swift
//  AmericanoChallenge
//
//  Created by Luca Maria Incarnato on 06/12/24.
//

import Foundation
import SwiftUI

class Profile{
    var alarm: Alarm = Alarm()
    var streak: Int = 0 // Actual number of consecutive days where the user successfully wakes up and doesn't snooze
    // Placeholder Nights
    var backtrack: [Night] = [
        Night(date: Date.now.addingTimeInterval(-604800), duration: 60, wakeUpSuccess: true, snoozed: true),
        Night(date: Date.now.addingTimeInterval(-172800), duration: 60, wakeUpSuccess: true, snoozed: false),
        Night(date: Date.now.addingTimeInterval(-345600), duration: 60, wakeUpSuccess: true, snoozed: true)
    ]
    var restedDays: Int = 0 // Number of days the user preferred to rest and to not wake up at a specific hour
    var snoozedDays: Int = 0 // Number of days the user snoozed
    var totalSleepDuration: TimeInterval = 0
    var averageSleepDuration: TimeInterval = 0
    // Placeholder achievements
    var totalAchievements: [Achievement] = [
        Achievement(
            "Snooze conqueeror",
            "alarm.waves.left.and.right.fill",
            "A month without snoozing",
            true
        ),
        Achievement(
            "Master of throws",
            "basketball.fill",
            "100 throws completed",
            true
        ),
        Achievement(
            "Master of throws",
            "basketball.fill",
            "100 throws completed",
            false
        ),
    ]
    
    // Update all the profile
    func update(){
        updateStreak()
        updateRestedDays()
        updateSnoozedDays()
        updateSleepInfo()
    }
    
    // Update streak
    private func updateStreak(){
        // If last night was successful and didn't snooze, increase streak
        if(self.backtrack.last!.wakeUpSuccess && !self.backtrack.last!.snoozed) {
            self.streak += 1
            return
        }
        // If last night was not successful, the streak is lost
        self.streak = 0
        return
    }
    
    // Update restedDays
    private func updateRestedDays(){
        // Counts all the days the user could have used the app
        let timeSpan = Int(self.backtrack.first!.date.timeIntervalSince(self.backtrack.last!.date) / 86400)
        // Rested days are the one not backtracked, so points out the number of days the user didn't use the app (total - used)
        self.restedDays = timeSpan - self.backtrack.count
    }
    
    // Update snoozedDays
    private func updateSnoozedDays(){
        for night in self.backtrack{
            if (night.snoozed) {self.snoozedDays += 1}
        }
    }
    
    // Update totalSleepDuration and averageSleepDuration
    private func updateSleepInfo(){
        // Adds, for each night, its duration
        for night in backtrack{
            self.totalSleepDuration += night.duration
        }
        // Arithmetic average
        self.averageSleepDuration = self.totalSleepDuration / Double(self.backtrack.count)
    }
    
    // Returns a date as HH:mm string
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }
}
