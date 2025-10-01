//
//  Night.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 06/12/24.
//

import SwiftData
import Foundation

@Model
class TNight: Identifiable{
    // MARK: ATTRIBUTES
    var id: UUID = UUID()
    var date: Date = Date.now // TODO: Check if Calendar is better for tracking
    var snoozed: Bool = false
    
    // MARK: INITIALIZERS
    init(date: Date, snoozed: Bool) {
        setNight(date, snoozed)
    }
    
    // MARK: PUBLIC METHODS
    // Change night info
    func setNight(_ date: Date, _ snoozed: Bool) {
        if(date > Date.now) {return} // Doesn't allow the user to record a night that has not happened yet
        self.date = date
        self.snoozed = snoozed
    }
    
    // Check if the night that's going to be recorded is last night (cannot be before for temporal reasons)
    static func alreadyTracked(in backtrack: [TNight]) -> Bool {
        if backtrack.isEmpty {return false}
        if Calendar.current.isDate(Date.now, inSameDayAs: backtrack.last!.date) {return true}
        return false
    }
}

// Container for mock data
extension TNight {
    @MainActor
    static var preview: ModelContainer {
        let container = try! ModelContainer(for: TNight.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        container.mainContext.insert(TNight(date: Date.now.addingTimeInterval(0*(-86400)), snoozed: false))
        container.mainContext.insert(TNight(date: Date.now.addingTimeInterval(1*(-86400)), snoozed: false))
        container.mainContext.insert(TNight(date: Date.now.addingTimeInterval(2*(-86400)), snoozed: false))
        container.mainContext.insert(TNight(date: Date.now.addingTimeInterval(3*(-86400)), snoozed: false))
        container.mainContext.insert(TNight(date: Date.now.addingTimeInterval(4*(-86400)), snoozed: false))
        container.mainContext.insert(TNight(date: Date.now.addingTimeInterval(5*(-86400)), snoozed: false))
        container.mainContext.insert(TNight(date: Date.now.addingTimeInterval(6*(-86400)), snoozed: false))
        container.mainContext.insert(TNight(date: Date.now.addingTimeInterval(7*(-86400)), snoozed: true))
        container.mainContext.insert(TNight(date: Date.now.addingTimeInterval(8*(-86400)), snoozed: false))
        container.mainContext.insert(TNight(date: Date.now.addingTimeInterval(9*(-86400)), snoozed: false))
        container.mainContext.insert(TNight(date: Date.now.addingTimeInterval(10*(-86400)), snoozed: false))
        container.mainContext.insert(TNight(date: Date.now.addingTimeInterval(11*(-86400)), snoozed: false))
        container.mainContext.insert(TNight(date: Date.now.addingTimeInterval(12*(-86400)), snoozed: false))
        return container
    }
}
