//
//  DayView.swift
//  AmericanoChallenge
//
//  Created by Luca Maria Incarnato on 11/12/24.
//

import SwiftUI

// Shows a circle for each day of the previous week, with a color associated to the info about that
struct DayView: View {
    @State var user: Profile
    var day: Date
    var isExtendedView: Bool = false
    var text = ""
    var formatter: DateFormatter {
        let buffer = DateFormatter()
        buffer.dateFormat = "EEE"
        return buffer
    }
    
    var body: some View {
        let weekdayString = formatter.string(from: day)
        ZStack{
            Circle()
                .frame(width: 30, height: 30)
                .foregroundStyle(determineBackground())
            Text(isExtendedView ? text : String(weekdayString.prefix(1)))
                .foregroundStyle(checkTracking() ? Color.black : Color.white.opacity(0.3))
        }
        .padding(.trailing, 8)
    }
    
    // Return a color based on the tracking and snoozing information of the actual day
    func determineBackground() -> Color{
        // MARK: POOR CONTRAST RATIO, ASK DOMENICO FOR HELP
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
        let current = Calendar.current
        for night in user.backtrack {
            if (current.date(from: current.dateComponents([.year, .month, .day], from: night.date)) == current.date(from: current.dateComponents([.year, .month, .day], from: day))){return true}
        }
        return false
    }
    
    // Checks if the actual date is in the backtrack array and, if yes, also if that night the user snoozed
    func checkSnoozed() -> Bool{
        let current = Calendar.current
        for night in user.backtrack{
            if (current.date(from: current.dateComponents([.year, .month, .day], from: night.date)) == current.date(from: current.dateComponents([.year, .month, .day], from: day)) && night.snoozed){return true}
        }
        return false
    }
}
