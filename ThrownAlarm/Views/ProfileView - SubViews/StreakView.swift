//
//  StreakView.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 27/09/25.
//

import SwiftUI
import SwiftData
import Foundation

struct StreakView: View {
    // MARK: ATTRIBUTES
    @Query(sort: \TNight.date, order: .reverse) private var backtrack: [TNight]
    @Environment(\.modelContext) private var modelContext // ONLY FOR TESTING
    @AppStorage("streak") private var streak: Int = 0
    @AppStorage("snoozedDays") private var snoozedDays: Int = 0
        
    // MARK: VIEW BODY
    var body: some View {
        VStack (alignment: .leading){
            // MARK: Wake Up streak
            VStack (alignment: .leading){
                HStack{
                    Image(systemName: "flame.fill")
                        .foregroundStyle(Color.green)
                        .font(.title3)
                        .accessibilityHidden(true)
                    Text("Woke up")
                        .foregroundStyle(Color.green)
                        .bold()
                        .font(.title3)
                        .accessibilityHidden(true)
                }
                HStack{
                    Text("\(streak)")
                        .font(.largeTitle)
                        .bold()
                        .accessibilityHidden(true)
                    Text(streak == 1 ? "day" : "days")
                        .font(.title3)
                        .accessibilityHidden(true)
                }
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            // MARK: Number of Snoozed Days
            VStack (alignment: .leading){
                HStack{
                    Image(systemName: "battery.25percent")
                        .foregroundStyle(Color.red)
                        .font(.title3)
                        .accessibilityHidden(true)
                    Text("Snoozed")
                        .foregroundStyle(Color.red)
                        .bold()
                        .font(.title3)
                        .accessibilityHidden(true)
                }
                HStack {
                    Text("\(snoozedDays)")
                        .font(.largeTitle)
                        .bold()
                        .accessibilityHidden(true)
                    Text(snoozedDays == 1 ? "day" : "days")
                        .font(.title3)
                        .accessibilityHidden(true)
                }
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .onAppear() {
            updateProfile()
        }
    }
    
    // MARK: PRIVATE METHODS
    // Update the global variable based on how many consecutive days user woke up on first alarm and how many didn't
    private func updateProfile() {
        snoozedDays = 0
        streak = 0
        // Counts all the snoozed in the backtrack
        for night in backtrack{
            if (night.snoozed) {snoozedDays += 1}
        }
        // Reversed the backtrack array and counts from zero to last not snoozed day
        for (index, element) in backtrack.enumerated(){
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
