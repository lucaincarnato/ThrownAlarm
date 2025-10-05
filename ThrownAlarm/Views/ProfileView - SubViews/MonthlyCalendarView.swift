//
//  MonthlyCalendarView.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 27/09/25.
//

import SwiftUI
import SwiftData
import Foundation

struct MonthlyCalendarView: View {
    // MARK: ATTRIBUTES
    @Query(sort: \TNight.date, order: .forward) private var backtrack: [TNight]
    @State private var selectedMonth: Date = Date()
    let calendar = Calendar.current
    
    // MARK: VIEW BODY
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 15)
                .padding()
                .foregroundStyle(Color.gray.opacity(0.3))
            VStack {
                // MARK: Month Selector
                HStack {
                    Button{
                        selectedMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    }
                    .buttonStyle(.glassProminent)
                    Text(selectedMonth, format: .dateTime.year().month(.wide))
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity)
                    Button{
                        selectedMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
                    } label:{
                        Image(systemName: "chevron.right")
                            .font(.title2)
                    }
                    .buttonStyle(.glassProminent)
                }
                .padding()
                // MARK: Weekdays display
                HStack {
                    ForEach(calendar.shortWeekdaySymbols, id: \.self) { weekday in
                        Text(weekday)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)
                    }
                }
                // MARK: Day display
                let days = daysInMonth(for: selectedMonth)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                    ForEach(days, id: \.self) { day in
                        if let day = day {
                            DayView(tracked: checkTracking(day), snoozed: checkSnoozed(day), text: String(calendar.component(.day, from: day)))
                        } else {
                            Text("")
                        }
                    }
                }
                .frame(minHeight: 250)
            }
            .padding(20)
        }
    }
    
    // MARK: PRIVATE METHODS
    // Return an array of all the selected month's Date
    private func daysInMonth(for date: Date) -> [Date?] {
        var days: [Date?] = []
        let range = calendar.range(of: .day, in: .month, for: date)!
        let components = calendar.dateComponents([.year, .month], from: date)
        let firstDayOfMonth = calendar.date(from: components)!
        let weekdayOffset = calendar.component(.weekday, from: firstDayOfMonth) - 1
        days.append(contentsOf: Array(repeating: nil, count: weekdayOffset))
        for day in range {
            if let dayDate = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(dayDate)
            }
        }
        return days
    }
    
    // Check if the parameter Date has been tracked
    private func checkTracking(_ day: Date) -> Bool{
        if backtrack.isEmpty{return false}
        let current = Calendar.current
        for night in backtrack {
            if (current.date(from: current.dateComponents([.year, .month, .day], from: night.date)) == current.date(from: current.dateComponents([.year, .month, .day], from: day))){return true}
        }
        return false
    }
    
    // Check if the user snoozed in parameter Date
    private func checkSnoozed(_ day: Date) -> Bool{
        if backtrack.isEmpty{return false}
        let current = Calendar.current
        for night in backtrack{
            if (current.date(from: current.dateComponents([.year, .month, .day], from: night.date)) == current.date(from: current.dateComponents([.year, .month, .day], from: day)) && night.snoozed){return true}
        }
        return false
    }
}
