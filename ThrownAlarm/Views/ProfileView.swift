//
//  Profile.swift
//  ThrownAlarm
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

private struct StreakView: View {
    @AppStorage("streak") private var streak: Int = 0
    @AppStorage("snoozedDays") private var snoozedDays: Int = 0
        
    var body: some View {
        VStack (alignment: .leading){
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
            .padding(.top, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
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
            .padding(.top, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityLabel("You snoozed for a total of \(snoozedDays == 1 ? "\(snoozedDays) day" : "\(snoozedDays) days")")
        }
        .padding([.horizontal, .top], 20)
    }
}

private struct MonthlyCalendarView: View {
    let calendar = Calendar.current
    @State private var selectedMonth: Date = Date()
    
    var body: some View {
        ZStack{
            if #available(iOS 26.0, *) {
                RoundedRectangle(cornerRadius: 15)
                    .glassEffect(in: RoundedRectangle(cornerRadius: 15))
                    .padding()
                    .foregroundStyle(Color.gray.opacity(0.3))
            } else {
                RoundedRectangle(cornerRadius: 15)
                    .padding()
                    .foregroundStyle(Color.gray.opacity(0.3))
            }
            VStack {
                HStack {
                    Button{
                        selectedMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
                    } label: {
                        if #available(iOS 26.0, *) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .accessibilityLabel("Previous month")
                                .padding()
                                .glassEffect(.regular.interactive())
                        } else {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .accessibilityLabel("Previous month")
                                .padding()
                        }
                    }
                    Text(selectedMonth, format: .dateTime.year().month(.wide))
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity)
                    Button{
                        selectedMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
                    } label: {
                        if #available(iOS 26.0, *) {
                            Image(systemName: "chevron.right")
                                .font(.title2)
                                .accessibilityLabel("Next month")
                                .padding()
                                .glassEffect(.regular.interactive())
                        } else {
                            Image(systemName: "chevron.right")
                                .font(.title2)
                                .accessibilityLabel("Next month")
                                .padding()
                        }
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

private struct DayView: View {
    @Query private var backtrack: [Night]
    
    var day: Date
    var isExtendedView: Bool = false
    var text = ""
    var formatter: DateFormatter {
        let buffer = DateFormatter()
        buffer.dateFormat = "EEEE"
        return buffer
    }
    
    var body: some View {
        let weekdayString = formatter.string(from: day)
        ZStack{
            if #available(iOS 26.0, *), determineBackground() != Color.clear {
                RoundedRectangle(cornerRadius: 100)
                    .frame(width: 30, height: 30)
                    .foregroundStyle(determineBackground())
                    .glassEffect()
            } else {
                RoundedRectangle(cornerRadius: 100)
                    .frame(width: 30, height: 30)
                    .foregroundStyle(determineBackground())
            }
            Text(isExtendedView ? text : String(weekdayString.prefix(1)))
                .bold()
                .foregroundStyle(checkTracking() ? Color.black : Color.white.opacity(0.3))
                .accessibilityHidden(!checkTracking())
                .accessibilityLabel(checkTracking() ? "\(isExtendedView ? text : weekdayString) \(checkTracking() ? (checkSnoozed() ? "Snoozed the alarm" : "Woke up") : "Didn't use the alarm")" : "")
        }
        .padding(.trailing, 8)
    }
    
    func determineBackground() -> Color{
        if (!checkTracking()){
            return Color.clear
        } else if (checkSnoozed()){
            return Color.red
        } else {
            return Color.green
        }
    }
    
    func checkTracking() -> Bool{
        if backtrack.isEmpty{return false}
        let current = Calendar.current
        for night in backtrack {
            if (current.date(from: current.dateComponents([.year, .month, .day], from: night.date)) == current.date(from: current.dateComponents([.year, .month, .day], from: day))){return true}
        }
        return false
    }
    
    func checkSnoozed() -> Bool{
        if backtrack.isEmpty{return false} 
        let current = Calendar.current
        for night in backtrack{
            if (current.date(from: current.dateComponents([.year, .month, .day], from: night.date)) == current.date(from: current.dateComponents([.year, .month, .day], from: day)) && night.snoozed){return true}
        }
        return false
    }
}
