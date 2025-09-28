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
            alarm.weekdays.append(weekday)
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
    }
}
