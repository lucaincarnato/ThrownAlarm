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
        scheduleLocalNotifications()
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
    
    func scheduleLocalNotifications() {
        for i in 0..<20 {
            let content = UNMutableNotificationContent()
            content.title = "Ehi! Apri l'app!"
            content.body = "Notifica \(i + 1) su 10. Abbiamo qualcosa di interessante per te."
            content.sound = .criticalSoundNamed(UNNotificationSoundName("alarm.wav"))
            content.badge = NSNumber(value: i + 1) // Mostra il badge progressivo sull'icona dell'app

            // Configura il trigger per ogni notifica con un intervallo crescente
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(i * 2 + 1), repeats: false)

            let request = UNNotificationRequest(identifier: "notification\(i)", content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Errore nella programmazione della notifica \(i + 1): \(error)")
                } else {
                    print("Notifica \(i + 1) programmata con successo.")
                }
            }
        }
    }


}
