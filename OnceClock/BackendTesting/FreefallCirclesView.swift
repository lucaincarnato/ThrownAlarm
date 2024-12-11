//
//  CirclePhysicsView.swift
//  AmericanoChallenge
//
//  Created by Luca Maria Incarnato on 11/12/24.
//

import SwiftUI
import UIKit

struct CircleModel: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGSize
}

struct FreefallCirclesView: View {
    @State private var circles: [CircleModel] = []
    @State private var timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect() // 60 FPS
    @State private var remainingCirclesCount: Int = 0 // Contatore dei cerchi rimanenti

    private let initialCircleCount = 10 // Numero fisso di cerchi
    private let launchSpeedReductionFactor: CGFloat = 10.0 // Fattore per ridurre la velocità del lancio
    private let dynamicIslandRect = CGRect(x: 140, y: -50, width: 140, height: 60) // Posizione e dimensioni della Dynamic Island

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Area della Dynamic Island (visibile solo per debugging)
                Rectangle()
                    .fill(Color.red.opacity(0.5))
                    .frame(width: dynamicIslandRect.width, height: dynamicIslandRect.height)
                    .position(x: dynamicIslandRect.midX, y: dynamicIslandRect.midY)

                // Mostra i cerchi
                ForEach(circles) { circle in
                    let circleRadius = calculateCircleRadius() // Calcola il raggio dinamico

                    Circle()
                        .fill(Color.orange)
                        .frame(width: circleRadius * 2, height: circleRadius * 2) // Usa il raggio calcolato
                        .position(circle.position)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    moveCircle(withID: circle.id, to: value.location)
                                }
                                .onEnded { value in
                                    let velocity = CGSize(
                                        width: value.translation.width / (0.016 * launchSpeedReductionFactor),
                                        height: value.translation.height / (0.016 * launchSpeedReductionFactor)
                                    )
                                    releaseCircle(withID: circle.id, withVelocity: velocity)
                                }
                        )
                }

                // Contatore dei cerchi rimanenti
                VStack {
                    Text("Cerchi rimasti: \(remainingCirclesCount)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        .padding(.top, 50)
                    Spacer()
                }
            }
            .background(Color.black.ignoresSafeArea())
            .onAppear {
                generateInitialCircles(in: geometry.size)
            }
            .onReceive(timer) { _ in
                updateCircles(in: geometry.size)
            }
        }
    }

    private func generateInitialCircles(in size: CGSize) {
        for _ in 0..<initialCircleCount {
            let randomPosition = CGPoint(
                x: CGFloat.random(in: 30...(size.width - 30)),
                y: CGFloat.random(in: 30...(size.height - 30))
            )
            let randomVelocity = CGSize.zero
            let newCircle = CircleModel(position: randomPosition, velocity: randomVelocity)
            circles.append(newCircle)
        }
        remainingCirclesCount = circles.count // Aggiorna il contatore iniziale
    }

    private func moveCircle(withID id: UUID, to position: CGPoint) {
        if let index = circles.firstIndex(where: { $0.id == id }) {
            circles[index].position = position
            circles[index].velocity = .zero // Resetta la velocità durante il drag
        }
    }

    private func releaseCircle(withID id: UUID, withVelocity velocity: CGSize) {
        if let index = circles.firstIndex(where: { $0.id == id }) {
            circles[index].velocity = velocity
        }
    }

    private func updateCircles(in size: CGSize) {
        // Aggiorna la posizione e la velocità dei cerchi
        circles = circles.compactMap { circle in
            var newCircle = circle

            // Aggiorna la posizione basata sulla velocità
            newCircle.position.x += newCircle.velocity.width * 0.016
            newCircle.position.y += newCircle.velocity.height * 0.016

            // Aggiunge gravità
            newCircle.velocity.height += 500 * 0.016

            // Rimbalza sui bordi
            if newCircle.position.x <= calculateCircleRadius() || newCircle.position.x >= size.width - calculateCircleRadius() {
                newCircle.velocity.width *= -0.8
                newCircle.position.x = min(max(newCircle.position.x, calculateCircleRadius()), size.width - calculateCircleRadius())
            }
            if newCircle.position.y <= calculateCircleRadius() || newCircle.position.y >= size.height - calculateCircleRadius() {
                newCircle.velocity.height *= -0.8
                newCircle.position.y = min(max(newCircle.position.y, calculateCircleRadius()), size.height - calculateCircleRadius())
            }

            // Elimina il cerchio se entra nella Dynamic Island
            let circleFrame = CGRect(
                x: newCircle.position.x - calculateCircleRadius(),
                y: newCircle.position.y - calculateCircleRadius(),
                width: calculateCircleRadius() * 2,
                height: calculateCircleRadius() * 2
            )
            if circleFrame.intersects(dynamicIslandRect) {
                triggerHapticFeedback() // Esegui il feedback aptico
                remainingCirclesCount -= 1 // Aggiorna il contatore
                return nil // Rimuove il cerchio
            }

            return newCircle
        }
    }

    private func calculateCircleRadius() -> CGFloat {
        // Calcola il raggio in base al numero iniziale di cerchi
        let maxRadius: CGFloat = 60
        let minRadius: CGFloat = 30
        let radius = max(minRadius, maxRadius - CGFloat(initialCircleCount) * 5)
        return radius
    }

    private func triggerHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

#Preview {
    FreefallCirclesView()
}

/**
 private let launchSpeedReductionFactor: CGFloat = 10.0 // Fattore per ridurre la velocità del lancio
 private let dynamicIslandRect = CGRect(x: 140, y: -50, width: 140, height: 60) // Posizione e dimensioni della Dynamic Island
 */
