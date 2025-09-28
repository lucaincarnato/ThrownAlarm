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
    @Query private var backtrack: [TNight]
    @Environment(\.modelContext) private var modelContext
    
    @AppStorage("userStreak") private var streak: Int = 0
    @AppStorage("userSnoozedDays") private var snoozedDays: Int = 0
    
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
    
    private func updateProfile() -> Void {
        snoozedDays = 0
        for night in backtrack{
            if (night.snoozed) {snoozedDays += 1}
        }
        for (index, element) in backtrack.reversed().enumerated(){
            if element.snoozed {
                streak = index
                return
            }
        }
        streak = backtrack.count
        return
    }
}
