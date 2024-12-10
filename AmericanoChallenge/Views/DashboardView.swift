//
//  DashboardView.swift
//  AmericanoChallenge
//
//  Created by Luca Maria Incarnato on 08/12/24.
//

import SwiftUI
import Foundation

// Shows the Gamification dashboard, it is the entry point of the application
struct DashboardView: View {
    @State var user: Profile = Profile() // Returns the info about the user profile
    @State var alarmActive: Bool = true // Tells if the alarm is active, enabling the system to track the hour
    @State var setAlarm: Bool = false // Boolean value for the modality
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack( alignment: .leading, spacing: 0){
                    // Card for the info about the alarm
                    AlarmView(user: $user, alarmActive: $alarmActive, setAlarm: $setAlarm)
                    // Card for the basic streak info that links to the related page
                    NavigationLink{
                        ProfileView(user: $user, selectedDate: Date.now)
                    } label: {
                        StreakView(user: $user)
                    }
                    // Section dedicated to the achievements
                    VStack (alignment: .leading){
                        // Label that redirects to the achievements view
                        NavigationLink{
                            AchievementsView(user: $user)
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
                                ForEach(user.totalAchievements){ achievement in
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
                    SetAlarmView(user: $user, setAlarm: $setAlarm)
                }
            }
            .navigationTitle("Dashboard")
        }
    }
}

// Card to show the info about the alarm
private struct AlarmView: View{
    @Binding var user: Profile // Binding value for the user profile
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
                        Text("Your alarm")
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
                    HStack{
                        let alarm = user.alarm
                        // From
                        Text(user.formatDate(alarm.sleepTime))
                            .font(.largeTitle)
                            .bold()
                            .foregroundStyle(Color.white)
                        Image(systemName: "arrow.forward")
                            .foregroundStyle(Color.accentColor)
                            .padding(.horizontal)
                        // To
                        Text(user.formatDate(alarm.wakeTime))
                            .font(.largeTitle)
                            .bold()
                            .foregroundStyle(Color.white)
                    }
                    .padding(.vertical, 10)
                }
                // Info about the duration of the sleep
                let intDuration = Int(user.alarm.sleepDuration / 3600)
                let intMinutes = Int(Int(user.alarm.sleepDuration) % 3600 / 60)
                let stringDuration = intDuration > 1 ? "Rings in \(intDuration)h:\(intMinutes)m" : "Rings in \(intDuration)h:\(intMinutes)m"
                // MARK: THIS IS THE DURATION, NOT THE TIME REMAINING
                Text(stringDuration)
                    .foregroundStyle(Color.accentColor)
            }
        }
        .frame(height: 200)
    }
}

// Card to show basic info about the streak
private struct StreakView: View {
    @Binding var user: Profile // Binding value for the user profile
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
                        let weekdayString = formatter.string(from: day)
                        DayView(user: $user, day: day)
                    }
                    
                }
                .padding(.horizontal, 40)
            }
        }
        .frame(height: 245)
    }
}

// Shows a circle for each day of the previous week, with a color associated to the info about that
private struct DayView: View {
    @Binding var user: Profile
    var day: Date
    var formatter: DateFormatter {
        let buffer = DateFormatter()
        buffer.dateFormat = "EEE"
        return buffer
    }
    
    var body: some View {
        let weekdayString = formatter.string(from: day)
        ZStack{
            Circle()
                .frame(width: 30, height: 30)
                .foregroundStyle(determineBackground())
            Text(String(weekdayString.prefix(1)))
                .foregroundStyle(checkTracking() ? Color.black : Color.white)
        }
        .padding(.trailing, 8)
    }
    
    // Return a color based on the tracking and snoozing information of the actual day
    func determineBackground() -> Color{
        // MARK: POOR CONTRAST RATIO, ASK DOMENICO FOR HELP
        if (!checkTracking()){
            return Color.clear
        } else if (checkSnoozed()){
            return Color.red
        } else {
            return Color.green
        }
    }
    
    // See if the actual day is in the backtrack array, meaning that the user used the app
    func checkTracking() -> Bool{
        let current = Calendar.current
        for night in user.backtrack {
            if (current.date(from: current.dateComponents([.year, .month, .day], from: night.date)) == current.date(from: current.dateComponents([.year, .month, .day], from: day))){return true}
        }
        return false
    }
    
    // Checks if the actual date is in the backtrack array and, if yes, also if that night the user snoozed
    func checkSnoozed() -> Bool{
        let current = Calendar.current
        for night in user.backtrack{
            if (current.date(from: current.dateComponents([.year, .month, .day], from: night.date)) == current.date(from: current.dateComponents([.year, .month, .day], from: day)) && night.snoozed){return true}
        }
        return false
    }
}

// Card to show the achievement and its info (Not private because referenced in AchievementsView
struct AchievementCardView: View{
    var achievement: Achievement // Achievement's model
    @State var isShowing: Bool = false // Boolean value for the modality of achievement's info
    
    var body: some View{
        // All the view is showed as a button that enables a small modal with achievement's info
        Button(){
            isShowing.toggle()
        } label: {
            ZStack{
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(Color.gray.opacity(0.3))
                // Shows actual text and image if the achievement has been achieved, otherwise placeholders
                VStack{
                    Text(achievement.achieved ? achievement.name : "Unlocked")
                        .font(.title3)
                        .bold()
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.white)
                    Image(systemName: achievement.achieved ? achievement.imageName : "questionmark.app.dashed")
                        .font(.largeTitle)
                        .foregroundStyle(Color.accentColor)
                        .padding(.vertical, 10)
                }
            }
            .frame(width: 150, height: 225)
            .opacity(achievement.achieved ? 1 : 0.5) // If the achievement is not achieved, the card is not completely visible
        }
        .disabled(!achievement.achieved) // If the achievement is not achieved, the user can't see its info
        // Modal view for the achievement's info
        .sheet(isPresented: $isShowing) {
            // Shows achievement's name, image and description
            VStack{
                Text(achievement.name)
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.top)
                Image(systemName: achievement.imageName)
                    .font(.custom("Achievement", fixedSize: 100))
                    .foregroundStyle(Color.accentColor)
                    .padding(.vertical, 10)
                Text(achievement.description)
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)
            }
            .presentationDetents([.height(280)]) // Force the modality to be small
        }
    }
}

#Preview {
    DashboardView()
}


/*
 Ho un DatePicker grafico nel mio progetto SwiftUI e vorrei usarlo per mostrare delle informazioni; in particolare vorrei cambiare lo sfondo di ogni giorno del picker sulla base di una variabile booleana: senza sfondo se è falsa e con uno sfondo verde se è vera. Come posso ottenere questo comportamento? 
 */
