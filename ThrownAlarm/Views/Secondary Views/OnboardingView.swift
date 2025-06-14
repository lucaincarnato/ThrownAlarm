//
//  OnboardingView.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 24/12/24.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var firstLaunch: Bool
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack{
            VStack {
                Image("IconImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 85, height: 85)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay{
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 1)
                            .opacity(0.5)
                    }
                    .padding()
                Text("Welcome to ThrownAlarm")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .bold()
                    .frame(maxWidth: .infinity)
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
                Button() {
                    requestNotificationPermission()
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
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error while asking permission: \(error.localizedDescription)")
            }
        }
    }
}

private struct PageView: View {
    var title: String = ""
    var content: String = ""
    var imageName: String = ""
    
    var body: some View {
        HStack(alignment: .center) {
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
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .bold()
                Text(content)
                    .font(.subheadline)
                    .opacity(0.7)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
        .padding(.horizontal, 30)
    }
}
