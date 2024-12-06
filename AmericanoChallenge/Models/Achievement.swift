//
//  Achievement.swift
//  AmericanoChallenge
//
//  Created by Luca Maria Incarnato on 06/12/24.
//

import Foundation

class Achievement{
    var name: String = "You lazy mf"
    var imageName: String = "l.joystick.fill"
    var description: String = "Don't snooze your alarm!"
    
    // Generic initializer
    init(name: String, imageName: String, description: String) {
        self.name = name
        self.imageName = imageName
        self.description = description
    }
}
