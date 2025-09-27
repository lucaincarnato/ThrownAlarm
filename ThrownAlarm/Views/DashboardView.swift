//
//  DashboardView.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 08/12/24.
//

import SwiftUI
import SwiftData
import Foundation
import AlarmKit

struct DashboardView: View {
    @AppStorage("Onboarding") var onboarding: Bool = false
    
    @Query private var alarms: [TAlarm]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack{
            ZStack{
                if alarms.isEmpty {
                    Text("No alarms")
                        .font(.subheadline)
                        .padding()
                        .foregroundStyle(.gray)
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        ScrollView{
                            ForEach(alarms, id: \.self) { alarm in
                                AlarmView(alarm: alarm)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Alarms")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button() {
                        let newAlarm = TAlarm(
                            sleepTime: Alarm.Schedule.Relative.Time(hour: 0, minute: 0),
                            wakeTime: Alarm.Schedule.Relative.Time(hour: 8, minute: 0)
                        )
                        modelContext.insert(newAlarm)
                        try? modelContext.save()
                    } label: {
                        Label("", systemImage: "plus")
                            .foregroundStyle(.accent)
                    }
                }
            }
            .task {
                let _ = await requestAlarmPermission()
                requestNotificationPermission()
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error while asking permission: \(error.localizedDescription)")
            }
        }
    }
    
    private func requestAlarmPermission() async -> Bool {
        switch AlarmManager.shared.authorizationState {
        case .notDetermined:
            do {
                return try await AlarmManager.shared.requestAuthorization() == .authorized
            } catch {
                return false
            }
        case .authorized:
            return true
        case .denied:
            return true
            
        @unknown default:
            return false
        }
    }
}
