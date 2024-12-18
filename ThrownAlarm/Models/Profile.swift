//
//  Profile.swift
//  AmericanoChallenge
//
//  Created by Luca Maria Incarnato on 06/12/24.
//

import Foundation
import SwiftUI
import SwiftData
import CloudKit

@Model
class Profile{
    @Attribute(.unique) var alarm: Alarm = Alarm()
    var streak: Int = 0 // Actual number of consecutive days where the user successfully wakes up and doesn't snooze
    // Placeholder Nights
    var backtrack: [Night] = []
    var snoozedDays: Int = 0 // Number of days the user snoozed
    var isActive: Bool = false // Determines if the user needs to be woke up by the alarm
    // Placeholder achievements
    var totalAchievements: [Achievement] = [
        Achievement(
            "Snooze conqueeror",
            "alarm.waves.left.and.right.fill",
            "A month without snoozing",
            false
        ),
        Achievement(
            "Master of throws",
            "basketball.fill",
            "100 throws completed",
            false
        ),
        Achievement(
            "Master of throws",
            "basketball.fill",
            "100 throws completed",
            false
        ),
    ]
    
    // General initializer to allow model 
    init(){
        self.streak = 0
        self.snoozedDays = 0
        self.backtrack = []
    }
    
    // Update streak
    func updateStreak() -> Void{
        if(!self.backtrack.isEmpty && self.backtrack.last!.wakeUpSuccess && !self.backtrack.last!.snoozed) {
            // If last night was successful and didn't snooze, increase streak
            self.streak += 1
        } else {
            // If last night was not successful, the streak is lost
            self.streak = 0
        }
        self.snoozedDays -= 1 // It is the contribute firstly added when the user enters the app
    }
    
    func updateSnooze() -> Void{
        // Update snoozed days
        self.snoozedDays = 0
        for night in self.backtrack{
            if (night.snoozed) {self.snoozedDays += 1}
        }
    }
}
