//
//  Night.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 06/12/24.
//

import SwiftData
import Foundation

@Model
class Night: Identifiable{
    var id: UUID = UUID()
    var date: Date = Date.now
    var snoozed: Bool = false
    
    init(date: Date, snoozed: Bool) {
        setNight(date, snoozed)
    }
    
    func setNight(_ date: Date, _ snoozed: Bool) {
        if(date > Date.now) {return} // Doesn't allow the user to record a night that has not happened yet
        self.date = date
        self.snoozed = snoozed
    }
}
