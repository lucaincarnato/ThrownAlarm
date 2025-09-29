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
                            try? modelContext.save()
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
                setAlarm = alarm.created.timeIntervalSinceNow > -1
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
            
            
            // Converti tutto in minuti dall'inizio della giornata
            let futureTotalMinutes = alarm.wakeTime.hour * 60 + alarm.wakeTime.minute
            let currentTotalMinutes = hour * 60 + minute
            
            // Se l'orario futuro è prima o uguale all'orario corrente, assumiamo che sia il giorno successivo
            let minutesDifference = (futureTotalMinutes >= currentTotalMinutes)
            ? (futureTotalMinutes - currentTotalMinutes)
            : (24 * 60 - currentTotalMinutes + futureTotalMinutes)
            
            // Calcola ore e minuti da differenza in minuti
            let hours = minutesDifference / 60
            let minutes = minutesDifference % 60
            
            timeRemaining.hour = hours
            timeRemaining.minute = minutes
        }
    }
}
