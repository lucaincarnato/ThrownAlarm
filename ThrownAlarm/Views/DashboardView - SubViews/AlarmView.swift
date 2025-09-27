//
//  AlarmView.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 27/09/25.
//

import SwiftUI
import SwiftData
import Foundation
import AlarmKit

struct AlarmView: View{
    @Query private var backtrack: [TNight]
    @Environment(\.modelContext) private var modelContext
    
    @AppStorage("userStreak") private var streak: Int = 0
    @AppStorage("userSnoozedDays") private var snoozedDays: Int = 0
    @AppStorage("AlarmGame") private var alarmGame: Bool = false
    
    @State var alarm: TAlarm
    @State var setAlarm: Bool = false
    @State var timeRemaining: Alarm.Schedule.Relative.Time = Alarm.Schedule.Relative.Time(hour: 0, minute: 0)
        
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 15)
                .padding()
                .foregroundStyle(Color.gray.opacity(0.3))
            VStack{
                HStack{
                    Button{
                        setAlarm.toggle()
                    } label: {
                        Text("Schedule")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Color.white)
                    }
                    Toggle("", isOn: $alarm.active).toggleStyle(SwitchToggleStyle())
                        .onChange(of: alarm.active){ oldValue, newValue in
                            if !newValue {
                                alarm.cancelAlarm()
                            } else {
                                Task{ await alarm.setAlarm() }
                            }
                        }
                }
                .padding(.horizontal, 40)
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
                                Text(TAlarm.toString(alarm.sleepTime))
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
                                Text(TAlarm.toString(alarm.wakeTime))
                                    .font(.largeTitle)
                                    .bold()
                                    .foregroundStyle(Color.white)
                            }
                        }
                        Text(!alarm.active ? "Alarm disabled" : "Rings in \(TAlarm.toString(timeRemaining))")
                            .foregroundStyle(Color.accentColor)
                            .onAppear {
                                updateRemainingTime()
                                startTimer()
                            }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 40)
                }
            }
            .sheet(isPresented: $setAlarm){
                SetAlarmView(alarm: $alarm, setAlarm: $setAlarm)
            }
            .fullScreenCover(isPresented: $alarmGame) {
                AlarmGameView(alarm: $alarm, rounds: alarm.rounds)
                    .onAppear(){
                        if alreadyTracked(){
                            backtrack.last!.setNight(Date.now, backtrack.last!.snoozed)
                        } else {
                            modelContext.insert(TNight(date: Date.now, snoozed: true))
                        }
                        try? modelContext.save()
                    }
            }
        }
        .frame(height: 200)
        .contextMenu {
            Button (role: .destructive) {
                modelContext.delete(alarm)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .onAppear(){
            updateProfile()
        }
    }
    
    func updateProfile() -> Void {
        snoozedDays = 0
        for night in backtrack{
            if (night.snoozed) {snoozedDays += 1}
        }
        for (index, element) in backtrack.reversed().enumerated(){
            if element.snoozed {
                streak = index
                return
            }
        }
        streak = backtrack.count
        return
    }
    
    private func updateRemainingTime() {
        Task {
            await alarm.setAlarm()
        }
        let hour = Calendar.current.component(.hour, from: Date.now)
        let minute = Calendar.current.component(.minute, from: Date.now)
        timeRemaining.hour = alarm.sleepTime.hour - hour
        timeRemaining.minute = alarm.sleepTime.minute - minute
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            updateRemainingTime()
        }
    }
    
    private func alreadyTracked() -> Bool {
        if backtrack.isEmpty {return false}
        if Calendar.current.isDate(Date.now, inSameDayAs: backtrack.last!.date) {return true}
        return false
    }
}
