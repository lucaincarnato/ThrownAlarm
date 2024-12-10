//
//  ProfileView.swift
//  AmericanoChallenge
//
//  Created by Luca Maria Incarnato on 08/12/24.
//

import SwiftUI

// Shows the info about the user's streak
struct ProfileView: View {
    @Binding var user: Profile // Binding value for the user profile
    @State var selectedDate: Date // Date for the picker TODO: NEED TO SEE IF IT IS NECESSARY WITH CUSTOM COMPONENT
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack{
                    // Shows the streak
                    Image(systemName: "flame.fill")
                        .foregroundStyle(Color.accentColor)
                        .font(.largeTitle)
                        .padding(.vertical, 10)
                    Text("You successfully woke up for")
                        .font(.title3)
                    Text("\(user.streak) days")
                        .font(.largeTitle)
                        .bold()
                    // Month view where the user can see its backlog TODO: CUSTOM COMPONENT
                    DatePicker(
                        "Start Date",
                        selection: $selectedDate,
                        in: ...Date(),
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .background(content: {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(Color.gray.opacity(0.3))
                    })
                    .padding(10)
                    // Secondary information
                    HStack{
                        InfoView(title: "You rested", imageName: "battery.100percent.bolt", content: "\(user.restedDays) days", color: Color.green)
                        InfoView(title: "You snoozed", imageName: "battery.25percent", content: "\(user.snoozedDays) days", color: Color.red)
                    }
                    .frame(height: 200)
                    /* MARK: IS IT REALLY NEEDED
                    HStack{
                        InfoView(title: "You slept", imageName: "bed.double.fill", content: "\(Int(user.totalSleepDuration/3600)) hours", color: Color.accentColor)
                        InfoView(title: "On average", imageName: "powersleep", content: "\(Int(user.averageSleepDuration/3600)) hours", color: Color.accentColor)
                    }
                    .frame(height: 200)
                     */
                }
            }
            .navigationTitle("Your streak")
            .navigationBarTitleDisplayMode(.inline) // Forces the title to be in the toolbar
        }
    }
}

// Shows the little cards with marginal information
private struct InfoView: View{
    var title: String // Title related to the information
    var imageName: String // SF symbol related to the information
    var content: String // Complementary information to the title
    var color: Color // Symbol's color
        
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(Color.gray.opacity(0.3))
            // Shows the actual informations
            VStack{
                Text(title)
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                Image(systemName: imageName)
                    .foregroundStyle(color)
                    .font(.largeTitle)
                    .padding(.vertical, 3)
                Text(content)
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
            }
        }
        .padding(10)
    }
}
