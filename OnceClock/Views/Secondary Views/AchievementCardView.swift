//
//  AchievementCardView.swift
//  AmericanoChallenge
//
//  Created by Luca Maria Incarnato on 11/12/24.
//

import SwiftUI

// Card to show the achievement and its info (Not private because referenced in AchievementsView
struct AchievementCardView: View{
    var achievement: Achievement // Achievement's model
    @State var isShowing: Bool = false // Boolean value for the modality of achievement's info
    
    var body: some View{
        // All the view is showed as a button that enables a small modal with achievement's info
        Button(){
            isShowing.toggle()
        } label: {
            ZStack{
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(Color.gray.opacity(0.3))
                // Shows actual text and image if the achievement has been achieved, otherwise placeholders
                VStack{
                    Text(achievement.achieved ? achievement.name : "Unlocked")
                        .font(.title3)
                        .bold()
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.white)
                    Image(systemName: achievement.achieved ? achievement.imageName : "questionmark.app.dashed")
                        .font(.largeTitle)
                        .foregroundStyle(Color.accentColor)
                        .padding(.vertical, 10)
                }
            }
            .frame(width: 150, height: 225)
            .opacity(achievement.achieved ? 1 : 0.5) // If the achievement is not achieved, the card is not completely visible
        }
        .disabled(!achievement.achieved) // If the achievement is not achieved, the user can't see its info
        // Modal view for the achievement's info
        .sheet(isPresented: $isShowing) {
            // Shows achievement's name, image and description
            VStack{
                Text(achievement.name)
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.top)
                Image(systemName: achievement.imageName)
                    .font(.custom("Achievement", fixedSize: 100))
                    .foregroundStyle(Color.accentColor)
                    .padding(.vertical, 10)
                Text(achievement.achievementDescription)
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)
            }
            .presentationDetents([.height(280)]) // Force the modality to be small
        }
    }
}
