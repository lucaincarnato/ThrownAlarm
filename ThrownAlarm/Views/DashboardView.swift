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
    // MARK: ATTRIBUTES
    @Query(sort: \TAlarm.wakeTime.hour, order: .forward) private var alarms: [TAlarm]
    @Environment(\.modelContext) private var modelContext
    @AppStorage("Onboarding") var onboarding: Bool = true
    @State var setType: Bool = false
    
    // MARK: VIEW BODY
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
                                    .padding(.vertical, 5)
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
                ToolbarItem(placement: .topBarLeading) {
                    Button() {
                        setType = true
                    } label: {
                        Label("", systemImage: "basketball")
                            .foregroundStyle(.accent)
                    }
                }
            }
            .task {
                // Asks for permission before even starting the app
                let _ = await requestAlarmPermission()
                requestNotificationPermission()
            }
            .fullScreenCover(isPresented: $onboarding) {
                OnboardingView()
            }
            .sheet(isPresented: $setType) {
                ThrowTypesView(setType: $setType)
            }
        }
    }
    
    // MARK: PRIVATE METHODS
    // Asks for notification permission
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error while asking permission: \(error.localizedDescription)")
            }
        }
    }
    
    // Asks for alarm permission
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
