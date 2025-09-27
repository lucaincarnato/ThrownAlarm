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
