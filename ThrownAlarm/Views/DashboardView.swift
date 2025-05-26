//
//  DashboardView.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 08/12/24.
//

import SwiftUI
import SwiftData
import Foundation
import FreemiumKit

// Shows the Gamification dashboard, it is the entry point of the application
struct DashboardView: View {
    // Boolean variable for the onboarding
    @AppStorage("firstLaunch") var firstLaunch: Bool = true // UserDefault to enable onboarding
    
    // Context and query to get info from database
    @Query private var alarms: [Alarm] // Query to access the user's alarms
    @Environment(\.modelContext) private var modelContext // Context needed for SwiftData operations
    
    var body: some View {
        NavigationStack{
            ZStack{
                // Communicate the absence of alarms
                if alarms.isEmpty {
                    Text("No alarms")
                        .font(.subheadline)
                        .padding()
                        .foregroundStyle(.gray)
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        // Paywall to show only first alarm and button to pay
                        PaidFeatureView {
                            ScrollView{
                                // Cards for the info about the alarms
                                ForEach(alarms, id: \.self) { alarm in
                                    AlarmView(alarm: alarm, isFirst: false)
                                }
                            }
                        } lockedView: {
                            AlarmPaidView(alarm: alarms.first!)
                        }
                    }
                }
            }
            .navigationTitle("Alarms")
            // Enables adding alarms
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    // Paywall to enable adding only after paying
                    PaidFeatureView{
                        Button() {
                            let newAlarm = Alarm()
                            modelContext.insert(newAlarm)
                            try? modelContext.save()
                        } label: {
                            Image(systemName: "plus")
                        }
                    } lockedView: {
                        Label("", systemImage: "plus")
                            .foregroundStyle(Color.accentColor)
                    }
                }
            }
            // Modality for the onboarding
            .sheet(isPresented: $firstLaunch) {
                OnboardingView(firstLaunch: $firstLaunch)
                    .interactiveDismissDisabled() // Disable closing interaction for modal
            }
        }
    }
}

// Card to show the info about the alarm
private struct AlarmView: View{
    @Query private var backtrack: [Night] // Query to access the backtrack of nights for streak updates
    @EnvironmentObject var deepLinkManager: DeepLinkManager // Deep link manager from the environment
    @Environment(\.modelContext) private var modelContext // Context needed for SwiftData operations
    @AppStorage("streak") private var streak: Int = 0 // UserDefault for nights' streak
    @AppStorage("snoozedDays") private var snoozedDays: Int = 0 // UserDefault for snoozed days
    
    @State var alarm: Alarm // Binding value for the user profile
    @State var isFirst: Bool // Determine if the alarm is the first free one
    @State var setAlarm: Bool = false // Binding value for the modality
    @State var sleepDuration: TimeInterval = 0
    @State var ringsIn: String = ""
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State var showAlert: Bool = false // Modality for the notification alert
    
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 15)
                .padding()
                .foregroundStyle(Color.gray.opacity(0.3))
            VStack{
                // Headline with title and toggle to check activityness
                HStack{
                    // Title shown as button that enables modal
                    Button{
                        setAlarm.toggle()
                    } label: {
                        Text("Schedule")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Color.white)
                            .accessibilityAddTraits(.isHeader)
                    }
                    .accessibilityAddTraits(.isButton)
                    Toggle("", isOn: $alarm.isActive).toggleStyle(SwitchToggleStyle()) // TODO: SAVE THAT INFO
                        .accessibilityAddTraits(.isToggle)
                        .accessibilityLabel("Activate alarm")
                    // Delete the alarm if the user turns it off
                        .onChange(of: alarm.isActive){ oldValue, newValue in
                            if !newValue{
                                alarm.clearAllNotifications()
                            } else {
                                alarm.setAlarm() // Makes eventual correction
                                alarm.sendNotification()
                            }
                        }
                }
                .padding(.horizontal, 40)
                // Alarm info showed as button that enables modal
                Button{
                    setAlarm.toggle()
                } label: {
                    VStack (alignment: .leading){
                        HStack{
                            VStack{
                                HStack{
                                    Image(systemName: "bed.double.fill")
                                        .foregroundStyle(Color.accentColor)
                                    Text("BEDTIME")
                                        .foregroundStyle(Color.accentColor)
                                        .font(.subheadline)
                                        .bold()
                                }
                                Text(alarm.sleepTime.formatted(date: .omitted, time: .shortened))
                                    .font(.largeTitle)
                                    .bold()
                                    .foregroundStyle(Color.white)
                            }
                            Image(systemName: "arrow.forward")
                                .foregroundStyle(Color.accentColor)
                                .padding(.horizontal)
                            VStack{
                                HStack{
                                    Image(systemName: "alarm.fill")
                                        .foregroundStyle(Color.accentColor)
                                    Text("WAKE UP")
                                        .foregroundStyle(Color.accentColor)
                                        .font(.subheadline)
                                        .bold()
                                }
                                Text(alarm.wakeTime.formatted(date: .omitted, time: .shortened))
                                    .font(.largeTitle)
                                    .bold()
                                    .foregroundStyle(Color.white)
                            }
                        }
                        // Live info about the duration of the sleep
                        Text(!alarm.isActive ? "Alarm disabled" : "Rings in \(ringsIn)")
                            .foregroundStyle(Color.accentColor)
                            .accessibilityLabel(!alarm.isActive ? "Alarm disabled" : "Rings in \(hours) hours and \(minutes) minutes")
                        // Everytime the text is rendered a timer from now to wake up time is created and updated
                            .onAppear {
                                updateRemainingTime()
                                startTimer()
                            }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading) // Allinea il contenuto alla sinistra dello schermo
                    .padding(.horizontal, 40)
                }
                .accessibilityAddTraits(.isButton)
            }
            // Modality for the alarm settings
            .sheet(isPresented: $setAlarm){
                SetAlarmView(alarm: $alarm, setAlarm: $setAlarm, isFirst: $isFirst, showAlert: $showAlert, placeholder: Alarm())
            }
            // Opens the minigame if the deep link is correct
            .fullScreenCover(
                isPresented: Binding(get: { deepLinkManager.id == alarm.id }, set: { newValue in print("Value changed")}),
                onDismiss: { updateProfile()
                }) {
                if deepLinkManager.targetView == .alarmView {
                    AlarmGameView(alarm: $alarm, rounds: alarm.rounds)
                }
            }
            // Alert for the Silent and Focus mode
            .alert("DISABLE SILENT MODE AND FOCUS MODE BEFORE GOING TO SLEEP", isPresented: $showAlert, actions: {}, message: {Text("The alarm can't work with those modes active")})
        }
        .frame(height: 200)
        // Allow the long press for the deletion and the share
        .contextMenu {
            // Delete button on context menu
            Button (role: .destructive) {
                modelContext.delete(alarm)
            } label: {
                Label(isFirst ? "Cannot delete alarm" : "Delete", systemImage: isFirst ? "exclamationmark.triangle.fill" : "trash")
            }
            .disabled(isFirst) // Disables if it is the first free alarm
        }
        // Opens modality if the alarm is just created
        .onAppear(){
            updateProfile()
            if alarm.justCreated {
                setAlarm = true
                alarm.justCreated = false
                try? modelContext.save()
            }
        }
    }
    
    // Updates the streak and the snoozed days based on backtrack
    func updateProfile() -> Void {
        // Update snoozed days
        snoozedDays = 0
        for night in backtrack{
            if (night.snoozed) {snoozedDays += 1}
        }
        // Update streak days by checking the reversed index of the first day snoozed
        for (index, element) in backtrack.reversed().enumerated(){
            if element.snoozed {
                streak = index
                return
            }
        }
        streak = backtrack.count // If never snoozed, the index should be last + 1, aka all
        return
    }
    
    // Get the time interval between now and wake up time and convert into string
    private func updateRemainingTime() {
        alarm.setAlarm()
        // Determine the time difference between now and the wake time
        let timeInterval = alarm.wakeTime.timeIntervalSince(Date.now)
        // Creates the component for the string
        hours = Int(timeInterval) / 3600
        minutes = ((Int(timeInterval) % 3600) / 60)
        ringsIn = String(format: "%02dh:%02dmin", hours, minutes)
    }
    
    // Create and schedule a timer, updated every second
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            updateRemainingTime()
        }
    }
}

// Shows the first free alarm and some card that represents alarms unlocked with Pro
private struct AlarmPaidView: View {
    @State var alarm: Alarm // First alarm reference
    
    var body: some View {
        ScrollView {
            AlarmView(alarm: alarm, isFirst: true) // Shows the first alarm
            // Shows a series of cards with a paywall
            ZStack{
                VStack{
                    ZStack{
                        RoundedRectangle(cornerRadius: 15)
                            .padding()
                            .foregroundStyle(Color.gray.opacity(0.2))
                            .frame(height: 200)
                        Text("Unlock more with ThrownAlarm Pro")
                            .foregroundStyle(Color.accentColor)
                    }
                    ZStack{
                        RoundedRectangle(cornerRadius: 15)
                            .padding()
                            .foregroundStyle(Color.gray.opacity(0.2))
                            .frame(height: 200)
                        Text("Unlock more with ThrownAlarm Pro")
                            .foregroundStyle(Color.accentColor)
                    }
                    ZStack{
                        RoundedRectangle(cornerRadius: 15)
                            .padding()
                            .foregroundStyle(Color.gray.opacity(0.2))
                            .frame(height: 200)
                        Text("Unlock more with ThrownAlarm Pro")
                            .foregroundStyle(Color.accentColor)
                    }
                }
            }
        }
        .scrollDisabled(true) // Does not allow scrolling
    }
}
