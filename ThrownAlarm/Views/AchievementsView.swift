//
//  AchievementsView.swift
//  AmericanoChallenge
//
//  Created by Luca Maria Incarnato on 08/12/24.
//

import SwiftUI

// Shows all the achievement, obtained or not, in a larger view
struct AchievementsView: View {
    @State var user: Profile // Returns the info about the user profile
    // Columns for the LazyVGrid
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        NavigationStack{
            ScrollView {
                // Places all the achievement card in a 2 columned grid
                LazyVGrid(columns: columns, spacing: 40) {
                    ForEach(user.totalAchievements){ achievement in
                        AchievementCardView(achievement: achievement)
                            .padding(.trailing)
                    }
                }
                .padding()
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline) // Forces the title to be in the toolbar
        }
    }
}
