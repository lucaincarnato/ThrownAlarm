//
//  Night.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 06/12/24.
//

import SwiftData
import Foundation

/// Model for user's tracked nights
@Model
class Night: Identifiable{
    // MARK: - Attributes
    /// Identifier needed for loop iteration
    var id: UUID = UUID()
    /// Date of the tracked night
    var date: Date = Date.now
    /// Information about successful waking up
    var snoozed: Bool = false
    
    // MARK: - Initializers
    /// Creates a new Night with custom info
    /// - Parameters:
    ///   - date: Date of the tracked night
    ///   - snoozed: Information about successful waking up
    init(date: Date, snoozed: Bool) {
        setNight(date, snoozed)
    }
    
    // MARK: - Public methods
    /// Changes current Night with custom info
    /// - Parameters:
    ///   - date: Date of the tracked night
    ///   - snoozed: Information about successful waking up
    func setNight(_ date: Date, _ snoozed: Bool) {
        if(date > Date.now) {return} // Doesn't allow the user to record a night that has not happened yet
        self.date = date
        self.snoozed = snoozed
    }
}
