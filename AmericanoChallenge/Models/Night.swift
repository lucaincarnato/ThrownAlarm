//
//  Night.swift
//  AmericanoChallenge
//
//  Created by Luca Maria Incarnato on 06/12/24.
//

import Foundation

class Night{
    var date: Date = Date.now
    var duration: TimeInterval = 0
    var wakeUpSuccess: Bool = true // I believe in people
    var snoozed: Bool = false
    
    // Initizlize the Night with user's info
    init(date: Date, duration: TimeInterval, wakeUpSuccess: Bool, snoozed: Bool) {
        setNight(date, duration, wakeUpSuccess, snoozed)
    }
    
    // Changes Night's information
    func setNight(_ date: Date, _ duration: TimeInterval, _ wakeUpSuccess: Bool, _ snoozed: Bool) {
        if(date > Date.now) {return} // Doesn't allow the user to record a night that has not happened yet
        self.date = date
        self.duration = duration
        self.wakeUpSuccess = wakeUpSuccess
        self.snoozed = snoozed
    }
}
