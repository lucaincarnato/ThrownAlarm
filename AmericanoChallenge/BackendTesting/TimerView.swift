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
    @State private var alarmOff: Bool = false
    @State private var timer: Timer?
    
    var body: some View {
        NavigationStack{
            VStack {
                DatePicker("Select time of waking up", selection: $alarmDate, displayedComponents: .hourAndMinute)
                    .onChange(of: alarmDate, {startTimer()})
                Text(formatTime() == "0" ? "00:00:00" : formatTime())
            }
            .fullScreenCover(isPresented: $alarmOff) {
                MinigameView(alarmOff: $alarmOff)
            }
        }
    }
    
    private func stopTimer(){
        timer?.invalidate()
        timeRemaining = 0
        alarmOff.toggle()
    }
    
    private func startTimer(){
        determineTimeRemaining()
        timer?.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
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
}

#Preview {
    TimerView()
}
