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
    
    // General initializer to allow model 
    init(){
        self.streak = 0
        self.snoozedDays = 0
        self.backtrack = []
    }
    
    // Update streak
    func updateProfile() -> Void {
        // Update snoozed days
        self.snoozedDays = 0
        for night in self.backtrack{
            if (night.snoozed) {self.snoozedDays += 1}
        }
        // Update streak days by checking the reversed index of the first day snoozed
        for (index, element) in self.backtrack.reversed().enumerated(){
            if !element.wakeUpSuccess && element.snoozed {
                self.streak = index
                return
            }
        }
        self.streak = self.backtrack.count // If never snoozed, the index should be last + 1, aka all
        return
    }
}
