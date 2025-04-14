//
//  OnboardingView.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 24/12/24.
//

import SwiftUI

// Shows a list of the features of the app when the user enters it for the first time
struct OnboardingView: View {
    @Binding var firstLaunch: Bool // Boolean value for the one time only modality
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack{
            VStack {
                // App icon shown on the top of the screen
                Image("IconImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 85, height: 85)
                    // Custom shape to show outline
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay{
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 1)
                            .opacity(0.5)
                    }
                    .padding()
                // Welcoming text
                Text("Welcome to ThrownAlarm")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .bold()
                    .frame(maxWidth: .infinity)
                // Vertical list of all the features of the app
                VStack {
                    PageView(
                        title: "Set an alarm",
                        content: "Decide your sleep schedule for the day, your alarm sound and the intensity",
                        imageName: "clock.fill"
                    )
                    PageView(
                        title: "Go to sleep",
                        content: "At bedtime you will only need to account for the bed, leave the rest to ThrownAlarm",
                        imageName: "bed.double.fill"
                    )
                    PageView(title: "Wake up playing",
                             content: "When the time comes, you can only stop the sound by playing... or throwing",
                             imageName: "alarm.fill"
                    )
                    PageView(title: "Your streak",
                             content: "Don't snooze, otherwise you will lose your streak and your progress",
                             imageName: "star.fill"
                    )
                }
                .padding(.vertical)
                // Button to close the onboarding and start the app
                Button() {
                    firstLaunch.toggle()
                    modelContext.insert(Alarm(false))
                    try? modelContext.save()
                } label: {
                    Text("Let's start")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
    }
}

// Single row of features' list
private struct PageView: View {
    var title: String = "" // Feature brief description
    var content: String = "" // Feature long description
    var imageName: String = "" // SF Symbol's image for that feature
    
    var body: some View {
        // Horizontally place image and texts
        HStack(alignment: .center) {
            // Set a custom frame for the SF Symbol in order to not disalign texts due to different image sizes
            ZStack {
                Color.clear
                    .frame(width: 32, height: 32)
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(Color.accentColor)
                    .padding(.trailing, 15)
            }
            // Vertically placing the two texts
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .bold()
                Text(content)
                    .font(.subheadline)
                    .opacity(0.7)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading) // Uniforma la larghezza
        .padding(.vertical, 10)
        .padding(.horizontal, 30)
    }
}
