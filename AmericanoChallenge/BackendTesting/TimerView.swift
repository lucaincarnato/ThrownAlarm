//
//  TimerView.swift
//  AmericanoChallenge
//
//  Created by Luca Maria Incarnato on 07/12/24.
//

import Foundation
import SwiftUI

struct TimerView: View {
    @State private var alarmDate: Date = Date.now.addingTimeInterval(15)
    @State private var timeRemaining: TimeInterval = 0
    @State private var isAlarmOn: Bool = false
    @State private var timer: Timer?
    
    var body: some View {
        NavigationStack{
            Form{
                DatePicker("Select time of waking up", selection: $alarmDate, displayedComponents: .hourAndMinute)
            }
            Text(formatTime())
            Button(){
                startTimer()
            } label: {
                Text("Start alarm")
            }
            Button(){
                stopTimer()
            } label: {
                Text("Stop alarm")
            }
            
            if(!isAlarmOn){
                Text("\(isAlarmOn)")
            }
        }
        .onAppear{
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if let error = error {
                    print("Errore durante la richiesta di permessi: \(error.localizedDescription)")
                } else if granted {
                    print("Permessi concessi.")
                } else {
                    print("Permessi negati.")
                }
            }
        }
    }
    
    private func stopTimer(){
        isAlarmOn.toggle()
        scheduleLocalNotification()
        timer?.invalidate()
        timeRemaining = 0
    }
    
    private func startTimer(){
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        isAlarmOn.toggle()
        determineTimeRemaining()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timeRemaining > 0 ? timeRemaining -= 1 : stopTimer()
        }
    }
    
    private func determineTimeRemaining(){
        if (alarmDate < Date.now) {alarmDate.addTimeInterval(86400)}
        self.timeRemaining = alarmDate.timeIntervalSinceNow
    }
    
    private func formatTime() -> String{
        let formatter = DateComponentsFormatter()
        return formatter.string(from: timeRemaining)!
    }
    
    func scheduleLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Ehi! Apri l'app!"
        content.body = "Abbiamo qualcosa di interessante per te."
        content.sound = .default
        content.badge = NSNumber(value: 1) // Mostra il badge sull'icona dell'app

        // Configura un intervallo di ripetizione
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(identifier: "repeatingNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Errore nella programmazione della notifica: \(error)")
            } else {
                print("Notifica programmata con successo.")
            }
        }
    }

}
