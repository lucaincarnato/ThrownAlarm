//
//  DashboardView.swift
//  AmericanoChallenge
//
//  Created by Luca Maria Incarnato on 08/12/24.
//

import SwiftUI
import SwiftData
import Foundation
import FreemiumKit

struct ProfileView: View {
    var body: some View {
        NavigationStack{
            ScrollView{
                StreakView()
                MonthlyCalendarView()
            }
            .navigationTitle("Streak")
        }
    }
}

// Shows the info about the user's streak
private struct StreakView: View {
    @AppStorage("streak") private var streak: Int = 0
    @AppStorage("snoozedDays") private var snoozedDays: Int = 0
        
    var body: some View {
        VStack (alignment: .leading){
            // Shows the streak
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
            .frame(maxWidth: .infinity, alignment: .leading) // Allinea il contenuto alla sinistra dello schermo
            .accessibilityLabel("You successfully woke up for \(streak > 1 ? "\(streak) day" : "\(streak) days")")
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
            .frame(maxWidth: .infinity, alignment: .leading) // Allinea il contenuto alla sinistra dello schermo
            .accessibilityLabel("You snoozed for a total of \(snoozedDays == 1 ? "\(snoozedDays) day" : "\(snoozedDays) days")")
        }
        .padding(20)
    }
}

// Shows user's backtracking
private struct MonthlyCalendarView: View {
    let calendar = Calendar.current
    @State private var selectedMonth: Date = Date()
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 15)
                .padding()
                .foregroundStyle(Color.gray.opacity(0.3))
            VStack {
                // Month selector
                HStack {
                    // Previous month
                    Button{
                        selectedMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .accessibilityLabel("Previous month")
                    }
                    Text(selectedMonth, format: .dateTime.year().month(.wide))
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity)
                    // Next month
                    Button{
                        selectedMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
                    } label:{
                        Image(systemName: "chevron.right")
                            .font(.title2)
                            .accessibilityLabel("Next month")
                    }
                }
                .padding()
                // Weekdays
                HStack {
                    ForEach(calendar.shortWeekdaySymbols, id: \.self) { weekday in
                        Text(weekday)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)
                    }
                }
                // Daily grid per month
                let days = daysInMonth(for: selectedMonth)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                    ForEach(days, id: \.self) { day in
                        if let day = day {
                            DayView(day: day, isExtendedView: true, text: String(calendar.component(.day, from: day)))
                        } else {
                            Text("") // Empty cells to complete the grid
                        }
                    }
                }
                .frame(minHeight: 250)
            }
            .padding(20)
        }
    }
    
    // Generate month's day as Date optional array
    private func daysInMonth(for date: Date) -> [Date?] {
        // Local variable setup
        var days: [Date?] = []
        let range = calendar.range(of: .day, in: .month, for: date)!
        let components = calendar.dateComponents([.year, .month], from: date)
        let firstDayOfMonth = calendar.date(from: components)!
        let weekdayOffset = calendar.component(.weekday, from: firstDayOfMonth) - 1
        // Empty cells before first day of the month
        days.append(contentsOf: Array(repeating: nil, count: weekdayOffset))
        // Month's day generation
        for day in range {
            if let dayDate = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(dayDate)
            }
        }
        return days
    }
}

// Shows a circle for each day of the previous week, with a color associated to the info about that
private struct DayView: View {
    @Query private var backtrack: [Night]
    
    var day: Date // Actual date of the card
    var isExtendedView: Bool = false // Checks if it is needed the number of the day (true) or just the letter (false)
    var text = "" // Text for the number of the day
    // Date formatter to return the letter of the day
    var formatter: DateFormatter {
        let buffer = DateFormatter()
        buffer.dateFormat = "EEEE"
        return buffer
    }
    
    var body: some View {
        let weekdayString = formatter.string(from: day)
        ZStack{
            RoundedRectangle(cornerRadius: 100)
                .frame(width: 30, height: 30)
                .foregroundStyle(determineBackground())
            Text(isExtendedView ? text : String(weekdayString.prefix(1)))
                .bold()
                .foregroundStyle(checkTracking() ? Color.black : Color.white.opacity(0.3))
                .accessibilityHidden(!checkTracking())
                .accessibilityLabel(checkTracking() ? "\(isExtendedView ? text : weekdayString) \(checkTracking() ? (checkSnoozed() ? "Snoozed the alarm" : "Woke up") : "Didn't use the alarm")" : "")
        }
        .padding(.trailing, 8)
    }
    
    // Return a color based on the tracking and snoozing information of the actual day
    func determineBackground() -> Color{
        if (!checkTracking()){
            return Color.clear
        } else if (checkSnoozed()){
            return Color.red
        } else {
            return Color.green
        }
    }
    
    // See if the actual day is in the backtrack array, meaning that the user used the app
    func checkTracking() -> Bool{
        if backtrack.isEmpty{return false} // Avoid crashing when dataset is empty
        let current = Calendar.current
        for night in backtrack {
            if (current.date(from: current.dateComponents([.year, .month, .day], from: night.date)) == current.date(from: current.dateComponents([.year, .month, .day], from: day))){return true}
        }
        return false
    }
    
    // Checks if the actual date is in the backtrack array and, if yes, also if that night the user snoozed
    func checkSnoozed() -> Bool{
        if backtrack.isEmpty{return false} // Avoid crashing when dataset is empty
        let current = Calendar.current
        for night in backtrack{
            if (current.date(from: current.dateComponents([.year, .month, .day], from: night.date)) == current.date(from: current.dateComponents([.year, .month, .day], from: day)) && night.snoozed){return true}
        }
        return false
    }
}
