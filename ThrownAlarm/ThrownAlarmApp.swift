//
//  ThrownAlarmApp.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 06/12/24.
//

import SwiftUI

@main
struct ThrownAlarmApp: App {
    var body: some Scene {
        WindowGroup {
            TabView{
                DashboardView()
                    .tabItem {
                        Label("Alarms", systemImage: "alarm.fill")
                    }
                ProfileView()
                    .tabItem {
                        Label("Streak", systemImage: "flame.fill")
                    }
            }
            .preferredColorScheme(.dark)
        }
        .modelContainer(for: [TAlarm.self, TNight.self], isAutosaveEnabled: false)
    }
}
