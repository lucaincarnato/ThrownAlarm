//
//  ProfileView.swift
//  AmericanoChallenge
//
//  Created by Luca Maria Incarnato on 08/12/24.
//

import SwiftUI
import SwiftData

// Shows the info about the user's streak
struct ProfileView: View {
    @State var user: Profile // Binding value for the user profile
    @State private var showSheet: Bool = false
    var contextUpdate: () throws -> Void
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack (alignment: .leading){
                    // Shows the streak
                    Image(systemName: "flame.fill")
                        .foregroundStyle(Color.green)
                        .font(.largeTitle)
                        .padding(.vertical, 10)
                    Text("You successfully woke up for")
                        .font(.title3)
                    Text("\(user.streak) days")
                        .font(.largeTitle)
                        .bold()
                    Image(systemName: "battery.25percent")
                        .foregroundStyle(Color.red)
                        .font(.largeTitle)
                        .padding(.vertical, 10)
                    Text("You snoozed for a total of")
                        .font(.title3)
                    Text("\(user.snoozedDays) days")
                        .font(.largeTitle)
                        .bold()
                }
                .frame(maxWidth: .infinity, alignment: .leading) // Allinea il contenuto alla sinistra dello schermo
                .padding(.horizontal, 20)
                MonthlyCalendarView(user: user)
                Button("Freefall"){
                    showSheet = true
                }
                .fullScreenCover(isPresented: $showSheet) {
                    AlarmGameView(user: $user, showSheet: $showSheet, contextUpdate: contextUpdate, rounds: user.alarm.rounds)
                }
            }
            .navigationTitle("Your streak")
            .navigationBarTitleDisplayMode(.inline) // Forces the title to be in the toolbar
        }
    }
}

private struct MonthlyCalendarView: View {
    @State var user: Profile // Binding value for the user profile
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
                    }
                    Text(selectedMonth, format: .dateTime.year().month(.wide))
                        .font(.title2)
                        .bold()
                    // Next month
                    Button{
                        selectedMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
                    } label:{
                        Image(systemName: "chevron.right")
                            .font(.title2)
                    }
                }
                .padding()
                // Weekdays
                HStack {
                    ForEach(calendar.shortWeekdaySymbols, id: \.self) { weekday in
                        Text(weekday)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.secondary)
                    }
                }
                // Daily grid per month
                let days = daysInMonth(for: selectedMonth)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                    ForEach(days, id: \.self) { day in
                        if let day = day {
                            DayView(user: user, day: day, isExtendedView: true, text: String(calendar.component(.day, from: day)))
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
