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
    @State private var selected: Bool = false
    @State var day: String = "M"
    @State var weekday: Locale.Weekday = .monday
    
    // MARK: VIEW BODY
    var body: some View {
        Button(){
            selected.toggle()
            // If selected and the weekday is not in the alarm, add it, if not selected and it is contained, remove it 
            if (selected && !alarm.weekdays.contains(weekday)) {
                alarm.weekdays.append(weekday)
            } else if (!selected && alarm.weekdays.contains(weekday)) {
                let index = alarm.weekdays.firstIndex(of: weekday)
                alarm.weekdays.remove(at: index!)
            }
        } label: {
            ZStack{
                Circle()
                    .foregroundStyle(selected ? Color.accentColor : Color.gray.opacity(0.3))
                    .frame(width: 40)
                Text(day)
                    .foregroundStyle(selected ? Color.black : Color.white)
                    .font(.title3)
                    .bold(selected)
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: selected)
        .onAppear { selected = alarm.weekdays.contains(weekday) }
    }
}
