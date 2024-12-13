//
//  AmericanoChallengeApp.swift
//  AmericanoChallenge
//
//  Created by Luca Maria Incarnato on 06/12/24.
//

import SwiftUI

@main
struct OnceClockApp: App {
    var body: some Scene {
        WindowGroup {
            DashboardView()
                .preferredColorScheme(.dark) // Forces the app to run in dark mode
        }
        .modelContainer(for: Profile.self)
    }
}
