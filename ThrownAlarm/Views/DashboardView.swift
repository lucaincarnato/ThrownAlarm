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

struct DashboardView: View {
    @AppStorage("firstLaunch") var firstLaunch: Bool = true
    
    @Query private var alarms: [Alarm]
    @Environment(\.modelContext) private var modelContext
    
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
            .sheet(isPresented: $firstLaunch) {
                OnboardingView(firstLaunch: $firstLaunch)
                    .interactiveDismissDisabled()
            }
        }
    }
}

private struct AlarmView: View{
    @Query private var backtrack: [Night]
    @EnvironmentObject var deepLinkManager: DeepLinkManager
    @Environment(\.modelContext) private var modelContext
    @AppStorage("streak") private var streak: Int = 0
    @AppStorage("snoozedDays") private var snoozedDays: Int = 0
    
    @State var alarm: Alarm
    @State var isFirst: Bool
    @State var setAlarm: Bool = false
    @State var sleepDuration: TimeInterval = 0
    @State var ringsIn: String = ""
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State var showAlert: Bool = false
    
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
                            .accessibilityAddTraits(.isHeader)
                    }
                    .accessibilityAddTraits(.isButton)
                    Toggle("", isOn: $alarm.isActive).toggleStyle(SwitchToggleStyle())
                        .accessibilityAddTraits(.isToggle)
                        .accessibilityLabel("Activate alarm")
                        .onChange(of: alarm.isActive){ oldValue, newValue in
                            if !newValue{
                                alarm.clearAllNotifications()
                            } else {
                                alarm.setAlarm()
                                alarm.sendNotification()
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
                        Text(!alarm.isActive ? "Alarm disabled" : "Rings in \(ringsIn)")
                            .foregroundStyle(Color.accentColor)
                            .accessibilityLabel(!alarm.isActive ? "Alarm disabled" : "Rings in \(hours) hours and \(minutes) minutes")
                            .onAppear {
                                updateRemainingTime()
                                startTimer()
                            }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 40)
                }
                .accessibilityAddTraits(.isButton)
            }
            .sheet(isPresented: $setAlarm){
                SetAlarmView(alarm: $alarm, setAlarm: $setAlarm, isFirst: $isFirst, showAlert: $showAlert, placeholder: Alarm())
            }
            .fullScreenCover(
                isPresented: Binding(get: { deepLinkManager.id == alarm.id }, set: { newValue in print("Value changed")}),
                onDismiss: { updateProfile()
                }) {
                if deepLinkManager.targetView == .alarmView {
                    AlarmGameView(alarm: $alarm, rounds: alarm.rounds)
                        .onAppear(){
                            if alreadyTracked() {
                                backtrack.last!.setNight(Date.now, true)
                            } else {
                                modelContext.insert(Night(date: Date.now, snoozed: true))
                            }
                            try? modelContext.save()
                        }
                }
            }
            .alert("DISABLE SILENT MODE AND FOCUS MODE BEFORE GOING TO SLEEP", isPresented: $showAlert, actions: {}, message: {Text("The alarm can't work with those modes active")})
        }
        .frame(height: 200)
        .contextMenu {
            Button (role: .destructive) {
                modelContext.delete(alarm)
            } label: {
                Label(isFirst ? "Cannot delete alarm" : "Delete", systemImage: isFirst ? "exclamationmark.triangle.fill" : "trash")
            }
            .disabled(isFirst)
        }
        .onAppear(){
            updateProfile()
            if alarm.justCreated {
                setAlarm = true
                alarm.justCreated = false
                try? modelContext.save()
            }
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
        alarm.setAlarm()
        let timeInterval = alarm.wakeTime.timeIntervalSince(Date.now)
        hours = Int(timeInterval) / 3600
        minutes = ((Int(timeInterval) % 3600) / 60)
        ringsIn = String(format: "%02dh:%02dmin", hours, minutes)
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

private struct AlarmPaidView: View {
    @State var alarm: Alarm
    
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
