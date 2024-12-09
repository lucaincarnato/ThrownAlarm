//
//  Achievement.swift
//  AmericanoChallenge
//
//  Created by Luca Maria Incarnato on 06/12/24.
//

import Foundation

class Achievement: Identifiable{
    var id: UUID = UUID()
    var name: String = "You lazy mf"
    var imageName: String = "l.joystick.fill"
    var description: String = "Don't snooze your alarm!"
    var achieved: Bool = false
    
    // Generic initializer
    init(_ name: String, _ imageName: String, _ description: String, _ achieved: Bool) {
        self.name = name
        self.imageName = imageName
        self.description = description
        self.achieved = achieved
    }
}
