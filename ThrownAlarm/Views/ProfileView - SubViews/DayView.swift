//
//  DayView.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 27/09/25.
//

import SwiftUI
import SwiftData
import Foundation

struct DayView: View {
    @Query private var backtrack: [TNight]
    
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
