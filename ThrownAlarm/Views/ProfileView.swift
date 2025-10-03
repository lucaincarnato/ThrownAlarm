//
//  Profile.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 08/12/24.
//

import SwiftUI
import SwiftData
import Foundation

struct ProfileView: View {
    // MARK: VIEW BODY
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
