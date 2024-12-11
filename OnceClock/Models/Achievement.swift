//
//  Achievement.swift
//  AmericanoChallenge
//
//  Created by Luca Maria Incarnato on 06/12/24.
//

import SwiftData
import Foundation

@Model
class Achievement: Identifiable{
    var id: UUID = UUID()
    var name: String = "You lazy mf"
    var imageName: String = "l.joystick.fill"
    var achievementDescription: String = "Don't snooze your alarm!"
    var achieved: Bool = false
    
    // Generic initializer
    init(_ name: String, _ imageName: String, _ achievementDescription: String, _ achieved: Bool) {
        self.name = name
        self.imageName = imageName
        self.achievementDescription = achievementDescription
        self.achieved = achieved
    }
}
