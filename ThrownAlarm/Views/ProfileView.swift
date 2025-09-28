//
//  Profile.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 08/12/24.
//

import SwiftUI
import SwiftData
import Foundation

struct ProfileView: View {
    // MARK: ATTRIBUTES
    @Query private var backtrack: [TNight]
    @Environment(\.modelContext) private var modelContext
    @AppStorage("userStreak") private var streak: Int = 0
    @AppStorage("userSnoozedDays") private var snoozedDays: Int = 0
    
    // MARK: VIEW BODY
    var body: some View {
        NavigationStack{
            ScrollView{
                StreakView()
                MonthlyCalendarView()
            }
            .navigationTitle("Streak")
            .onAppear {
                updateProfile()
            }
        }
    }
    
    // MARK: PRIVATE METHODS
    // Update the global variable based on how many consecutive days user woke up on first alarm and how many didn't
    private func updateProfile() -> Void {
        snoozedDays = 0
        // Counts all the snoozed in the backtrack
        for night in backtrack{
            if (night.snoozed) {snoozedDays += 1}
        }
        // Reverse the backtrack array and counts from zero to last not snoozed day
        for (index, element) in backtrack.reversed().enumerated(){
            if element.snoozed {
                streak = index
                return
            }
        }
        // Executed only if all days are not snoozed
        streak = backtrack.count
        return
    }
}
