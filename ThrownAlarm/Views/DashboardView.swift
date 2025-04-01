//
//  DashboardView.swift
//  AmericanoChallenge
//
//  Created by Luca Maria Incarnato on 08/12/24.
//

import SwiftUI
import SwiftData
import Foundation

// Shows the Gamification dashboard, it is the entry point of the application
struct DashboardView: View {
    // Boolean variable for the onboarding
    @AppStorage("firstLaunch") var firstLaunch: Bool = true
    // Context and query to get info from database
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [Profile]
    
    @EnvironmentObject var deepLinkManager: DeepLinkManager // Deep link manager from the environment
    
    var user: Profile? { // Returns the info about the first(and only) user profile of the database
        users.first ?? Profile()
    }
    @State var alarmActive: Bool = true // Tells if the alarm is active, enabling the system to track the hour
    @State var setAlarm: Bool = false // Boolean value for the modality
    
    @State var showAlert: Bool = false // MARK: BOOLEAN FOR THE SILENT AND FOCUS MODE ALERT, TO BE REMOVED
    
    var body: some View {
        NavigationStack{
            VStack( alignment: .leading, spacing: 0){
                // Card for the info about the alarm
                AlarmView(user: user!, setAlarm: $setAlarm, save: modelContext.save)
                StreakView(user: user!, save: modelContext.save)
                MonthlyCalendarView(user: user!)
            }
            // Modality for the alarm settings
            .sheet(isPresented: $setAlarm){
                SetAlarmView(user: user!, placeholder: Profile(), setAlarm: $setAlarm, save: modelContext.save, showAlert: $showAlert)
            }
            // MARK: ALERT FOR THE SILENT AND FOCUS MODE, TO BE REMOVED
            .alert("DISABLE SILENT MODE AND FOCUS MODE BEFORE GOING TO SLEEP", isPresented: $showAlert, actions: {}, message: {Text("The alarm can't work with those active yet")})
            .navigationTitle("Dashboard")
            .onAppear{
                if users.first == nil{
                    modelContext.insert(user!)
                }
                user!.updateProfile() // Updates the streak everytime the user enters the app (so also when the user has snoozed)
                try? modelContext.save()
            }
            // Updates the profile when the user completes the minigame (not checking with snoozed bc if snoozed the user exits the app and onAppear is called)
            .onChange(of: user!.backtrack.last?.wakeUpSuccess) { oldValue, newValue in
                user!.updateProfile()
            }
            // Opens the minigame if the deep link is correct
            .fullScreenCover(isPresented: $deepLinkManager.showModal) {
                if deepLinkManager.targetView == .alarmView {
                    AlarmGameView(user: user!, showSheet: $deepLinkManager.showModal, save: modelContext.save)
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

// Card to show the info about the alarm
private struct AlarmView: View{
    @State var user: Profile // Binding value for the user profile
    @Binding var setAlarm: Bool // Binding value for the modality
    @State var sleepDuration: TimeInterval = 0
    @State var ringsIn: String = ""
    
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    
    var save: () throws -> Void // Context update
    
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
                        Text("Your schedule")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Color.white)
                            .accessibilityAddTraits(.isHeader)
                    }
                    .accessibilityAddTraits(.isButton)
                    Toggle("", isOn:$user.isActive).toggleStyle(SwitchToggleStyle()) // TODO: SAVE THAT INFO
                        .accessibilityAddTraits(.isToggle)
                        .accessibilityLabel("Activate alarm")
                    // Delete the alarm if the user turns it off
                        .onChange(of: user.isActive){ oldValue, newValue in
                            if !newValue{
                                user.alarm.clearAllNotifications()
                            } else {
                                user.alarm.sendNotification()
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
                                Text(user.alarm.sleepTime.formatted(date: .omitted, time: .shortened))
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
                                Text(user.alarm.wakeTime.formatted(date: .omitted, time: .shortened))
                                    .font(.largeTitle)
                                    .bold()
                                    .foregroundStyle(Color.white)
                            }
                        }
                        // Live info about the duration of the sleep
                        Text(!user.isActive ? "Alarm disabled" : "Rings in \(ringsIn)")
                            .foregroundStyle(Color.accentColor)
                            .accessibilityLabel(!user.isActive ? "Alarm disabled" : "Rings in \(hours) hours and \(minutes) minutes")
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
        }
        .frame(height: 200)
    }
    
    // Get the time interval between now and wake up time and convert into string
    private func updateRemainingTime() {
        let now = Date()
        // Determine the time difference between now and the wake time
        let timeInterval = user.alarm.wakeTime.timeIntervalSince(now)
        // Creates the component for the string
        if timeInterval > 0 {
            hours = Int(timeInterval) / 3600
            minutes = ((Int(timeInterval) % 3600) / 60)
            ringsIn = String(format: "%02dh:%02dmin", hours, minutes)
        } else {
            ringsIn = "An error occurred, reschedule"
        }
    }
    
    // Create and schedule a timer, updated every second
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            updateRemainingTime()
        }
    }
    
}

// Shows the info about the user's streak
private struct StreakView: View {
    @State var user: Profile // Binding value for the user profile
    @State private var showSheet: Bool = false
    var save: () throws -> Void
    
    var body: some View {
        HStack{
            VStack (alignment: .leading){
                // Shows the streak
                Image(systemName: "flame.fill")
                    .foregroundStyle(Color.green)
                    .font(.title)
                    .padding(.vertical, 2)
                    .accessibilityHidden(true)
                Text("You woke up for")
                    .font(.headline)
                    .accessibilityLabel("You woke up for \(user.streak > 1 ? "\(user.streak) day" : "\(user.streak) days")")
                Text(user.streak == 1 ? "\(user.streak) day" : "\(user.streak) days")
                    .font(.title)
                    .bold()
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, alignment: .leading) // Allinea il contenuto alla sinistra dello schermo
            .padding(.horizontal, 20)
            VStack (alignment: .leading){
                // Shows the streak
                Image(systemName: "battery.25percent")
                    .foregroundStyle(Color.red)
                    .font(.title)
                    .padding(.vertical, 9)
                    .accessibilityHidden(true)
                Text("You snoozed")
                    .font(.headline)
                    .accessibilityLabel("You snoozed \(user.snoozedDays == 1 ? "\(user.snoozedDays) day" : "\(user.snoozedDays) days")")
                Text(user.snoozedDays == 1 ? "\(user.snoozedDays) day" : "\(user.snoozedDays) days")
                    .font(.title)
                    .bold()
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, alignment: .leading) // Allinea il contenuto alla sinistra dello schermo
            .padding(.horizontal, 20)
        }
    }
}

// Shows user's backtracking
private struct MonthlyCalendarView: View {
    @State var user: Profile // Binding value for the user profile
    let calendar = Calendar.current
    @State private var selectedMonth: Date = Date()
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 15)
                .padding()
                .foregroundStyle(Color.gray.opacity(0.3))
            VStack {
                // Month selector
                HStack {
                    // Previous month
                    Button{
                        selectedMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .accessibilityLabel("Previous month")
                    }
                    Text(selectedMonth, format: .dateTime.year().month(.wide))
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity)
                    // Next month
                    Button{
                        selectedMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
                    } label:{
                        Image(systemName: "chevron.right")
                            .font(.title2)
                            .accessibilityLabel("Next month")
                    }
                }
                .padding()
                // Weekdays
                HStack {
                    ForEach(calendar.shortWeekdaySymbols, id: \.self) { weekday in
                        Text(weekday)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)
                    }
                }
                // Daily grid per month
                let days = daysInMonth(for: selectedMonth)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                    ForEach(days, id: \.self) { day in
                        if let day = day {
                            DayView(user: user, day: day, isExtendedView: true, text: String(calendar.component(.day, from: day)))
                        } else {
                            Text("") // Empty cells to complete the grid
                        }
                    }
                }
                .frame(minHeight: 250)
            }
            .padding(20)
        }
    }
    
    // Generate month's day as Date optional array
    private func daysInMonth(for date: Date) -> [Date?] {
        // Local variable setup
        var days: [Date?] = []
        let range = calendar.range(of: .day, in: .month, for: date)!
        let components = calendar.dateComponents([.year, .month], from: date)
        let firstDayOfMonth = calendar.date(from: components)!
        let weekdayOffset = calendar.component(.weekday, from: firstDayOfMonth) - 1
        // Empty cells before first day of the month
        days.append(contentsOf: Array(repeating: nil, count: weekdayOffset))
        // Month's day generation
        for day in range {
            if let dayDate = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(dayDate)
            }
        }
        return days
    }
}
