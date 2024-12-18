//
//  DashboardView.swift
//  AmericanoChallenge
//
//  Created by Luca Maria Incarnato on 08/12/24.
//

import SwiftUI
import SwiftData
import CloudKit
import Foundation

// Shows the Gamification dashboard, it is the entry point of the application
struct DashboardView: View {
    // Context and query to get info from database
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [Profile]
    
    @EnvironmentObject var deepLinkManager: DeepLinkManager // Deep link manager from the environment
    
    var user: Profile? { // Returns the info about the first(and only) user profile of the database
        users.first ?? Profile()
    }
    @State var alarmActive: Bool = true // Tells if the alarm is active, enabling the system to track the hour
    @State var setAlarm: Bool = false // Boolean value for the modality
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack( alignment: .leading, spacing: 0){
                    // Card for the info about the alarm
                    AlarmView(user: user!, setAlarm: $setAlarm, save: modelContext.save)
                    // Card for the basic streak info that links to the related page
                    NavigationLink{
                        ProfileView(user: user!, save: modelContext.save)
                    } label: {
                        StreakView(user: user!)
                    }
                    // Section dedicated to the achievements
                    VStack (alignment: .leading){
                        // Label that redirects to the achievements view
                        NavigationLink{
                            AchievementsView(user: user!)
                        } label: {
                            HStack{
                                Text("Achievements")
                                    .font(.title2)
                                    .foregroundStyle(Color.white)
                                    .bold()
                                    .accessibilityAddTraits(.isHeader)
                                Image(systemName: "chevron.forward")
                                    .font(.title2)
                                    .foregroundStyle(Color.white)
                                    .bold()
                            }
                        }
                        // Smaller and quicker view of all the achievement
                        ScrollView (.horizontal){
                            HStack{
                                if user!.totalAchievements.isEmpty {
                                    Text("Not available yet")
                                        .font(.subheadline)
                                        .padding()
                                } else {
                                    ForEach(user!.totalAchievements){ achievement in
                                        AchievementCardView(achievement: achievement)
                                            .padding(.trailing)
                                    }
                                }
                            }
                        }
                        .defaultScrollAnchor(.leading) // Anchors the element to the leading part of the screen
                    }
                    .padding()
                }
                // Modality for the alarm settings
                .sheet(isPresented: $setAlarm){
                    SetAlarmView(user: user!, placeholder: Profile(), setAlarm: $setAlarm, save: modelContext.save)
                }
            }
            .navigationTitle("Dashboard")
            .onAppear{
                if users.first == nil{
                    modelContext.insert(user!)
                }
            }
            // Opens the minigame if the deep link is correct
            .fullScreenCover(isPresented: $deepLinkManager.showModal) {
                if deepLinkManager.targetView == .alarmView {
                    AlarmGameView(user: user!, showSheet: $deepLinkManager.showModal, save: modelContext.save)
                }
            }
        }
    }
}

// Card to show the info about the alarm
private struct AlarmView: View{
    @State var user: Profile // Binding value for the user profile
    @Binding var setAlarm: Bool // Binding value for the modality
    @State var sleepDuration: TimeInterval = 0
    
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
                        // Info about the duration of the sleep
                        let intDuration = Int(user.alarm.ringsIn / 3600)
                        let intMinutes = Int(Int(user.alarm.ringsIn) % 3600 / 60)
                        let stringDuration = intDuration > 1 ? "Rings in \(intDuration)h:\(intMinutes)m" : "Rings in \(intDuration)h:\(intMinutes)m"
                        Text(user.isActive ? stringDuration : "Alarm disabled")
                            .foregroundStyle(Color.accentColor)
                            .padding(.bottom, 10)
                            .accessibilityLabel(user.isActive ? "Rings in \(intDuration) hours and \(intMinutes) minutes" : "Alarm disabled")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading) // Allinea il contenuto alla sinistra dello schermo
                    .padding(.horizontal, 40)
                }
                .accessibilityAddTraits(.isButton)
            }
        }
        .frame(height: 200)
    }
}

// Card to show basic info about the streak
private struct StreakView: View {
    @State var user: Profile // Binding value for the user profile
    // Returns the seven date of the previous week
    let lastSevenDays = (0...6).compactMap { dayOffset in
        Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date())
    }
    // Returns a formatter in order to get the weekday name (to then show in the DayView
    var formatter: DateFormatter {
        let buffer = DateFormatter()
        buffer.dateFormat = "EEE"
        return buffer
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .padding()
                .foregroundStyle(Color.gray.opacity(0.3))
            VStack (alignment: .leading){
                // Headline for the title
                HStack{
                    Text("Your streak")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(Color.white)
                        .frame(alignment: .leading)
                        .padding(.bottom, 5)
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                }
                .padding(.horizontal, 40)
                // Displays the streak main info
                HStack{
                    Image(systemName: "flame.fill")
                        .foregroundStyle(Color.accentColor)
                        .font(.largeTitle)
                    Text(user.streak == 1 ? "\(user.streak) day" : "\(user.streak) days")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(Color.white)
                }
                .padding(.bottom, 5)
                .padding(.horizontal, 40)
                // Describes the way user used the app in the previous 7 days
                Text("Your past week")
                    .foregroundStyle(Color.accentColor)
                    .padding(.bottom, 10)
                    .padding(.horizontal, 40)
                // Shows seven circles with the weekdays, filled or coloured based on that day's info
                HStack{
                    ForEach(lastSevenDays.reversed(), id:\.self){ day in
                        DayView(user: user, day: day)
                    }
                    
                }
                .padding(.horizontal, 40)
            }
        }
        .frame(height: 245)
    }
}

#Preview{
    DashboardView()
        .modelContainer(try! ModelContainer(for: Profile.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)))
}
