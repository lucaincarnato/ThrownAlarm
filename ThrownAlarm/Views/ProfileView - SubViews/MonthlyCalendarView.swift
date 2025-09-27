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
    let calendar = Calendar.current
    @State private var selectedMonth: Date = Date()
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 15)
                .padding()
                .foregroundStyle(Color.gray.opacity(0.3))
            VStack {
                HStack {
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
                    Button{
                        selectedMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
                    } label:{
                        Image(systemName: "chevron.right")
                            .font(.title2)
                            .accessibilityLabel("Next month")
                    }
                }
                .padding()
                HStack {
                    ForEach(calendar.shortWeekdaySymbols, id: \.self) { weekday in
                        Text(weekday)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)
                    }
                }
                let days = daysInMonth(for: selectedMonth)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                    ForEach(days, id: \.self) { day in
                        if let day = day {
                            DayView(day: day, isExtendedView: true, text: String(calendar.component(.day, from: day)))
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
}
