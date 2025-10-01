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
            videoName: "Quack",
            title: "Benvenuto in ThrownAlarm",
            description: "Imposta una sveglia e ThrownAlarm ti avviserà con una notifica quando sarà tempo di andare a dormire."
        ),
        OnboardingStep(
            videoName: "Quack",
            title: "Svegliati con un plus",
            description: "Quando sarà il momento, ThrownAlarm ti sveglierà con una piccola sfida per iniziare al meglio la giornata"
        ),
        OnboardingStep(
            videoName: "Quack",
            title: "Tieni traccia del tuo sonno",
            description: "Non perdere il focus, traccia le tue mattine e svegliati ogni giorno sempre più carico."
        )
    ]

    var body: some View {
        ZStack {
            VStack(spacing: 40) {
                VideoPlayer(url: Bundle.main.url(forResource: "\(steps[currentStep].videoName)", withExtension: "mp4")!, play: .constant(true))
                    .autoReplay(true)
                    .frame(width: 200, height: 400)
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
                    Text(currentStep < steps.count - 1 ? "Next (\(currentStep + 1)/\(steps.count))" : "Inizia")
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
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
