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
    @State private var timer = Timer.publish(every: 0.01667, on: .main, in: .common).autoconnect() // 60 FPS
    @State private var remainingCirclesCount: Int = 0 // Counter for remaining circles

    private let initialCircleCount = 10 // Starting number of circles
    private let launchSpeedReductionFactor: CGFloat = 10.0 // Velocity reduction factor
    private let dynamicIslandRect = CGRect(x: 140, y: -50, width: 140, height: 60) // Collider position, near dynamic island

    var body: some View {
        // Geometric plane where items will be displayed
        GeometryReader { geometry in
            ZStack {
                // Collider outline, visible only for debugging
                Rectangle()
                    .fill(Color.red.opacity(0.5))
                    .frame(width: dynamicIslandRect.width, height: dynamicIslandRect.height)
                    .position(x: dynamicIslandRect.midX, y: dynamicIslandRect.midY)

                // Shows circles
                ForEach(circles) { circle in
                    let circleRadius = calculateCircleRadius() // Dynamically determine circle radius, based on number of circles
                    // Actual circle shape
                    Circle()
                        .fill(Color.orange)
                        .frame(width: circleRadius * 2, height: circleRadius * 2) // Usa il raggio calcolato
                        .position(circle.position)
                        // Allows moving and throwing
                        .gesture(
                            DragGesture()
                                // Moves the circle when user drags it
                                .onChanged { value in
                                    moveCircle(withID: circle.id, to: value.location)
                                }
                                // Changes velocity once user releases the circle
                                .onEnded { value in
                                    let velocity = CGSize(
                                        width: value.translation.width / (0.016 * launchSpeedReductionFactor),
                                        height: value.translation.height / (0.016 * launchSpeedReductionFactor)
                                    )
                                    releaseCircle(withID: circle.id, withVelocity: velocity)
                                }
                        )
                }

                // Remaining circles counter
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
            // Generates circles when the view loads
            .onAppear {
                generateInitialCircles(in: geometry.size)
            }
            // Updates the view at each frame, seeing if there's been collision
            .onReceive(timer) { _ in
                updateCircles(in: geometry.size)
            }
        }
    }

    // Generate the initial circles
    private func generateInitialCircles(in size: CGSize) {
        // Creates the logical circle (not the shape) and place randomly in the space
        for _ in 0..<initialCircleCount {
            let randomPosition = CGPoint(
                x: CGFloat.random(in: 30...(size.width - 30)),
                y: CGFloat.random(in: 30...(size.height - 30))
            )
            let randomVelocity = CGSize.zero // Starting velocity = 0
            circles.append(CircleModel(position: randomPosition, velocity: randomVelocity))
        }
        remainingCirclesCount = circles.count // Initialize the counter to the starting number of items
    }

    // Update circle's position on drag and set its velocity to zero
    private func moveCircle(withID id: UUID, to position: CGPoint) {
        if let index = circles.firstIndex(where: { $0.id == id }) {
            circles[index].position = position
            circles[index].velocity = .zero // Reset velocity to zero to not let the user lose the circle while dragging it
        }
    }

    // When the user releases the circle, it reinsert the velocity
    private func releaseCircle(withID id: UUID, withVelocity velocity: CGSize) {
        // Reinsert velocity into circle's movement
        if let index = circles.firstIndex(where: { $0.id == id }) {
            circles[index].velocity = velocity
        }
    }

    private func updateCircles(in size: CGSize) {
        // Updates circle's position and velocity each frame
        circles = circles.compactMap { circle in
            // Buffer circle
            var newCircle = circle
            // Update position based on velocity
            newCircle.position.x += newCircle.velocity.width * 0.016
            newCircle.position.y += newCircle.velocity.height * 0.016
            // Adds vertical velocity (aka gravity)
            newCircle.velocity.height += 500 * 0.016
            // Bounces off bezels
            if newCircle.position.x <= calculateCircleRadius() || newCircle.position.x >= size.width - calculateCircleRadius() {
                newCircle.velocity.width *= -0.8
                newCircle.position.x = min(max(newCircle.position.x, calculateCircleRadius()), size.width - calculateCircleRadius())
            }
            if newCircle.position.y <= calculateCircleRadius() || newCircle.position.y >= size.height - calculateCircleRadius() {
                newCircle.velocity.height *= -0.8
                newCircle.position.y = min(max(newCircle.position.y, calculateCircleRadius()), size.height - calculateCircleRadius())
            }
            // Deletes circle if it collides with dynamic island
            let circleFrame = CGRect(
                x: newCircle.position.x - calculateCircleRadius(),
                y: newCircle.position.y - calculateCircleRadius(),
                width: calculateCircleRadius() * 2,
                height: calculateCircleRadius() * 2
            )
            if circleFrame.intersects(dynamicIslandRect) {
                triggerHapticFeedback() // Returns haptic feedback if the ball collides
                remainingCirclesCount -= 1 // Updates counter
                return nil // Removes circle
            }
            return newCircle
        }
    }

    // Set a inverse proportional relationship between number of circles and their radius
    private func calculateCircleRadius() -> CGFloat {
        // Determine maximum and minimum radius
        let maxRadius: CGFloat = 60
        let minRadius: CGFloat = 30
        return max(minRadius, maxRadius - CGFloat(initialCircleCount) * 5) // Returns radius
    }

    // generate an haptic feedback response, simulated as notification
    private func triggerHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

#Preview {
    FreefallCirclesView()
}
