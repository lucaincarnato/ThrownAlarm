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
    // Context and query to get info from database
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [Profile]
    
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
                    AlarmView(user: user!, alarmActive: $alarmActive, setAlarm: $setAlarm)
                    // Card for the basic streak info that links to the related page
                    NavigationLink{
                        ProfileView(user: user!)
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
                                Image(systemName: "chevron.forward")
                                    .font(.title2)
                                    .foregroundStyle(Color.white)
                                    .bold()
                            }
                        }
                        // Smaller and quicker view of all the achievement
                        ScrollView (.horizontal){
                            HStack{
                                ForEach(user!.totalAchievements){ achievement in
                                    AchievementCardView(achievement: achievement)
                                        .padding(.trailing)
                                }
                            }
                        }
                        .defaultScrollAnchor(.leading) // Anchors the element to the leading part of the screen
                    }
                    .padding()
                }
                // Modality for the alarm settings
                .sheet(isPresented: $setAlarm){
                    SetAlarmView(user: user!, setAlarm: $setAlarm)
                }
            }
            .navigationTitle("Dashboard")
        }
    }
}

// Card to show the info about the alarm
private struct AlarmView: View{
    @State var user: Profile // Binding value for the user profile
    @Binding var alarmActive: Bool // Binding value for the activityness of the alarm
    @Binding var setAlarm: Bool // Binding value for the modality
    
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
                    }
                    Toggle("", isOn:$alarmActive).toggleStyle(SwitchToggleStyle())
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
                        let sleepDuration = (user.alarm.wakeTime.timeIntervalSinceReferenceDate - Date.now.timeIntervalSinceReferenceDate)
                        let intDuration = Int(sleepDuration / 3600)
                        let intMinutes = Int(Int(sleepDuration) % 3600 / 60)
                        let stringDuration = intDuration > 1 ? "Rings in \(intDuration)h:\(intMinutes)m" : "Rings in \(intDuration)h:\(intMinutes)m"
                        // MARK: THIS IS THE DURATION, NOT THE TIME REMAINING
                        Text(stringDuration)
                            .foregroundStyle(Color.accentColor)
                            .padding(.bottom, 10)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading) // Allinea il contenuto alla sinistra dello schermo
                    .padding(.horizontal, 40)
                }
            }
        }
        .frame(height: 200)
    }
}

// Card to show basic info about the streak
private struct StreakView: View {
    @State var user: Profile // Binding value for the user profile
    // Returns the seven date of the previous week
    let lastSevenDays = (1...7).compactMap { dayOffset in
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
                    Spacer()
                }
                .padding(.horizontal, 40)
                // Displays the streak main info
                HStack{
                    Image(systemName: "flame.fill")
                        .foregroundStyle(Color.accentColor)
                        .font(.largeTitle)
                    Text("\(user.streak) days")
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
