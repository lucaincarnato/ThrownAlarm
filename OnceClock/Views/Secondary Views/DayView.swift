//
//  DayView.swift
//  AmericanoChallenge
//
//  Created by Luca Maria Incarnato on 11/12/24.
//

import SwiftUI

// Shows a circle for each day of the previous week, with a color associated to the info about that
struct DayView: View {
    @State var user: Profile // Binding value for the user profile
    var day: Date // Actual date of the card
    var isExtendedView: Bool = false // Checks if it is needed the number of the day (true) or just the letter (false)
    var text = "" // Text for the number of the day
    // Date formatter to return the letter of the day
    var formatter: DateFormatter {
        let buffer = DateFormatter()
        buffer.dateFormat = "EEE"
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
                //.foregroundStyle( Color.white.opacity(checkTracking() ? 0.5 : 0.3))
                .foregroundStyle(checkTracking() ? Color.black : Color.white.opacity(0.3))
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
        if user.backtrack.isEmpty{return false} // Avoid crashing when dataset is empty
        let current = Calendar.current
        for night in user.backtrack {
            if (current.date(from: current.dateComponents([.year, .month, .day], from: night.date)) == current.date(from: current.dateComponents([.year, .month, .day], from: day))){return true}
        }
        return false
    }
    
    // Checks if the actual date is in the backtrack array and, if yes, also if that night the user snoozed
    func checkSnoozed() -> Bool{
        if user.backtrack.isEmpty{return false} // Avoid crashing when dataset is empty
        let current = Calendar.current
        for night in user.backtrack{
            if (current.date(from: current.dateComponents([.year, .month, .day], from: night.date)) == current.date(from: current.dateComponents([.year, .month, .day], from: day)) && night.snoozed){return true}
        }
        return false
    }
}
