//
//  WeeklyRepetitionView.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 28/09/25.
//

import SwiftUI

struct WeeklyRepetitionView: View {
    // MARK: ATTRIBUTES
    @Binding var alarm: TAlarm
    var day: String = "M"
    var weekvalue: Locale.Weekday = .monday
    var isSelected: Bool {
        alarm.weekdays.contains(weekvalue)
    }
    
    // MARK: VIEW BODY
    var body: some View {
        Button(){
            // If selected and the weekday is not in the alarm, add it, if not selected and it is contained, remove it
            if isSelected {
                alarm.weekdays.removeAll(where: { $0 == weekvalue })
            } else {
                alarm.weekdays.append(weekvalue)
            }
        } label: {
            ZStack{
                Circle()
                    .foregroundStyle(isSelected ? Color.accentColor : Color.clear)
                    .frame(width: 40)
                Text(day)
                    .foregroundStyle(isSelected ? Color.black : Color.white)
                    .font(.title3)
                    .bold(isSelected)
            }
        }
        .buttonStyle(.plain)
        .glassEffect(.clear.interactive(), in: Circle())
        .sensoryFeedback(.selection, trigger: isSelected)
        .id(weekvalue)
    }
}
