//
//  Alarm.swift
//  AmericanoChallenge
//
//  Created by Luca Maria Incarnato on 06/12/24.
//

import SwiftData
import Foundation

@Model
class Alarm{
    var sleepTime: Date = Date.now
    var wakeTime: Date = Date.now.addingTimeInterval(28800) // Sets the wake time 8h from the sleeps as default
    var sleepDuration: TimeInterval
    var sound: URL = URL(string: "https://www.youtube.com/watch?v=1111111111")! // TODO: FIGURE OUT HOW SOUND AND HAPTICS WORKS
    var haptics: URL = URL(string: "https://www.youtube.com/watch?v=1111111111")! // TODO: FIGURE OUT HOW SOUND AND HAPTICS WORKS
    var volume: Double = 0.5
    var rounds: Int = 3
    
    // Initializer for
    init () {
        // Compiler needs all properties to be initialized before calling method
        self.sleepDuration = 0
        self.setDuration()
    }
    
    // Sets the time interval as the difference between the time the user wakes up and the one when it goes to sleep
    func setDuration(){
        // If default values are kept, it should set sleepDuration to 86400
        self.sleepDuration = self.wakeTime.timeIntervalSinceReferenceDate - self.sleepTime.timeIntervalSinceReferenceDate
    }
    
    // Allow the user to change the time of go to sleep and wake up, updating the duration
    func setAlarm(_ sleepTime: Date, _ wakeTime: Date){
        // Doesn't allow the user to set the alarm for a date before the go to sleep one
        if(sleepTime > wakeTime) {
            self.wakeTime = wakeTime.addingTimeInterval(86400)
        }
        self.sleepTime = sleepTime
        self.wakeTime = wakeTime
        setDuration() // Automatically determine the sleep duration
    }
}
