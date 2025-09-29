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
    // MARK: ATTRIBUTES
    @Environment(\.modelContext) private var modelContext
    @AppStorage("AlarmGame") private var alarmGame: Bool = false
    @State var alarm: TAlarm
    @State var setAlarm: Bool = false
    @State var timeRemaining: Alarm.Schedule.Relative.Time = Alarm.Schedule.Relative.Time(hour: 0, minute: 0)
    
    // MARK: VIEW BODY
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 200 * 10 / 57)
                .foregroundStyle(Color.gray.opacity(0.3))
                .glassEffect(.clear.interactive(), in: RoundedRectangle(cornerRadius: 200 * 10 / 57))
                .padding()
            // MARK: Top section
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
                // MARK: Hour display
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
                        .padding(.vertical, 1)
                        // MARK: Rings in display
                        Text(!alarm.active ? "Alarm disabled" : "Rings in \(timeRemaining.hour)h \(timeRemaining.minute)min")
                            .foregroundStyle(Color.accentColor)
                            .onAppear { startTimer() }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 40)
                }
            }
            .padding(.horizontal, 4)
            .sheet(isPresented: $setAlarm){
                SetAlarmView(alarm: $alarm, setAlarm: $setAlarm)
                    .onDisappear { try? modelContext.save() } // Save modelContext for eventual unsaved changes
            }
            .fullScreenCover(isPresented: $alarmGame) {
                AlarmGameView(alarm: $alarm, rounds: alarm.rounds)
            }
            .onAppear() {
                setAlarm = alarm.created.timeIntervalSinceNow > -5
            }
        }
        .frame(height: 200)
        .contextMenu {
            Button (role: .destructive) {
                alarm.cancelAlarm()
                modelContext.delete(alarm)
                try? modelContext.save()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    // MARK: PRIVATE ATTRIBUTES
    // Start a timer to update the remaining time text
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let hour = Calendar.current.component(.hour, from: Date.now)
            let minute = Calendar.current.component(.minute, from: Date.now)
            // Normalize hour based on if wakeTime's hour is on tomorrow or within the day
            if (alarm.wakeTime.hour < hour) {
                timeRemaining.hour = 24 - hour + alarm.wakeTime.hour
            } else {
                timeRemaining.hour = alarm.wakeTime.hour - hour
            }
            // If wakeTime's hour and time's are the same, the hour remaining are max 24 (-1 for minutes)
            if (timeRemaining.hour == 0 && alarm.wakeTime.minute < minute) {timeRemaining.hour = 23}

            // Normalize minute based on if wakeTime'minute is on or after the current minute
            if (alarm.wakeTime.minute < minute) {
                timeRemaining.minute = 60 - minute + alarm.wakeTime.minute
            } else {
                timeRemaining.minute = alarm.wakeTime.minute - minute
            }
            if (timeRemaining.minute == 60) { timeRemaining.minute = 59 }
        }
    }
}
