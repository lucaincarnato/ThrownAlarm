//
//  DashboardView.swift
//  AmericanoChallenge
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
    @AppStorage("firstLaunch") var firstLaunch: Bool = true
    
    // Context and query to get info from database
    @Environment(\.modelContext) private var modelContext
    @Query private var alarms: [Alarm]
    @Query private var backtrack: [Night]
    
    @AppStorage("streak") private var streak: Int = 0
    @AppStorage("snoozedDays") private var snoozedDays: Int = 0
    
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
                        PaidFeatureView {
                            ScrollView{
                                // Cards for the info about the alarm
                                ForEach(alarms, id: \.self) { alarm in
                                    AlarmView(alarm: alarm, isFirst: false)
                                }
                            }
                        } lockedView: {
                            AlarmPaidView(alarm: alarms.first!)
                        }
                    }
                    .onAppear{
                        updateProfile() // Updates the streak everytime the user enters the app (so also when the user has snoozed)
                        try? modelContext.save()
                    }
                    // Updates the profile when the user completes the minigame (not checking with snoozed bc if snoozed the user exits the app and onAppear is called)
                    .onChange(of: backtrack.last?.wakeUpSuccess) { oldValue, newValue in
                        updateProfile()
                    }
                }
            }
            .navigationTitle("Alarms")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
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
    
    func updateProfile() -> Void {
        // Update snoozed days
        snoozedDays = 0
        for night in backtrack{
            if (night.snoozed) {snoozedDays += 1}
        }
        // Update streak days by checking the reversed index of the first day snoozed
        for (index, element) in backtrack.reversed().enumerated(){
            if !element.wakeUpSuccess && element.snoozed {
                streak = index
                return
            }
        }
        streak = backtrack.count // If never snoozed, the index should be last + 1, aka all
        return
    }
}

// Card to show the info about the alarm
private struct AlarmView: View{
    @State var alarm: Alarm // Binding value for the user profile
    @State var isFirst: Bool
    
    @State var setAlarm: Bool = false // Binding value for the modality
    @State var sleepDuration: TimeInterval = 0
    @State var ringsIn: String = ""
    
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State var showAlert: Bool = false
    
    @EnvironmentObject var deepLinkManager: DeepLinkManager // Deep link manager from the environment
    @Environment(\.modelContext) private var modelContext
    
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
                            alarm.setAlarm() // Avoid alarms in the past
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
                SetAlarmView(alarm: $alarm, placeholder: Alarm(), setAlarm: $setAlarm, isFirst: $isFirst, showAlert: $showAlert)
            }
            // Opens the minigame if the deep link is correct
            .fullScreenCover(isPresented: $deepLinkManager.showModal) {
                if deepLinkManager.targetView == .alarmView {
                    AlarmGameView(alarm: $alarm, showSheet: $deepLinkManager.showModal, save: modelContext.save)
                }
            }
            // MARK: ALERT FOR THE SILENT AND FOCUS MODE, TO BE REMOVED
            .alert("DISABLE SILENT MODE AND FOCUS MODE BEFORE GOING TO SLEEP", isPresented: $showAlert, actions: {}, message: {Text("The alarm can't work with those modes active")})
        }
        .frame(height: 200)
        // Allow the long press for the deletion and the share
        .contextMenu {
            // Delete
            Button (role: .destructive) {
                modelContext.delete(alarm)
            } label: {
                Label(isFirst ? "Cannot delete alarm" : "Delete", systemImage: isFirst ? "exclamationmark.triangle.fill" : "trash")
            }
            .disabled(isFirst)
        }
        .onAppear(){
            if alarm.justCreated {
                setAlarm = true
                alarm.justCreated = false
                try? modelContext.save()
            }
        }
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

private struct AlarmPaidView: View {
    var alarm: Alarm
    
    var body: some View {
        ScrollView {
            AlarmView(alarm: alarm, isFirst: true)
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
        .scrollDisabled(true)
    }
}
