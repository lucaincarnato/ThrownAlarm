//
//  OnboardingView.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 01/10/25.
//

import SwiftUI
import VideoPlayer

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("Onboarding") var onboarding: Bool = true
    @State private var currentStep = 0

    let steps = [
        OnboardingStep(
            videoName: "SetAlarm",
            title: "Welcome to ThrownAlarm",
            description: "Set an alarm and ThrownAlarm will notify when it's betime."
        ),
        OnboardingStep(
            videoName: "WakeUp",
            title: "Wake up with a plus",
            description: "On time, ThrownAlarm will wake you up with a little challenge to start the day on the right foot"
        ),
        OnboardingStep(
            videoName: "Streak",
            title: "Keep track of your mornings",
            description: "Don't lose focus, track your mornings and wake up every day feeling more energized."
        )
    ]

    var body: some View {
        ZStack {
            VStack(spacing: 40) {
                VideoPlayer(url: Bundle.main.url(forResource: "\(steps[currentStep].videoName)", withExtension: "mov")!, play: .constant(true))
                    .autoReplay(true)
                    .mute(true)
                    .frame(width: 1170/5, height: 2532/5)
                    .cornerRadius(16)
                Text(steps[currentStep].title)
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 40)
                    .animation(.smooth(duration: 0.5), value: currentStep)
                Text(steps[currentStep].description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 40)
                    .animation(.smooth(duration: 0.5), value: currentStep)
                Button() {
                    if currentStep < steps.count - 1 {
                        currentStep += 1
                    } else {
                        completeOnboarding()
                    }
                } label: {
                    Text(currentStep < steps.count - 1 ? "Next (\(currentStep + 1)/\(steps.count))" : "Inizia (\(steps.count)/\(steps.count))")
                        .font(.title3)
                        .bold()
                        .padding(.horizontal)
                }
                .padding(.horizontal, 40)
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private func completeOnboarding() {
        onboarding = false
        modelContext.insert(TAlarm())
    }
}

struct OnboardingStep {
    let videoName: String
    let title: String
    let description: String
}

#Preview {
    OnboardingView()
}
