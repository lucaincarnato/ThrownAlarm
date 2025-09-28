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
    // MARK: ATTRIBUTES
    var tracked: Bool = true
    var snoozed: Bool = true
    var text = ""
    
    // MARK: VIEW BODY 
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 100)
                .frame(width: 30, height: 30)
                .foregroundStyle(determineBackground())
            Text(text)
                .bold()
                .foregroundStyle(tracked ? Color.black : Color.white.opacity(0.3))
        }
        .padding(.trailing, 8)
    }
    
    // MARK: PRIVATE METHODS
    // Return a different color for the possible states of the day
    private func determineBackground() -> Color{
        if (!tracked){
            return Color.clear
        } else if (snoozed){
            return Color.red
        } else {
            return Color.green
        }
    }
}
