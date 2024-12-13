//
//  CirclePhysicsView.swift
//  AmericanoChallenge
//
//  Created by Luca Maria Incarnato on 11/12/24.
//

import SwiftUI

// Circle modeled, without shape, as vector
struct CircleModel: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGSize
}

// Shows the game space where the user can throw balls into the basket
struct AlarmGameView: View {
    @Binding var showSheet: Bool // Boolean value to allow modality
    
    @State var circles: [CircleModel] = [] // Array of logical circles
    @State var timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect() // Timer to update the scene at 60 FPS
    @State var remainingCirclesCount: Int = 0 // Remaining circles counter

    @State var initialCircleCount = 2 // Initial number of circles
    @State var round = 1 // Number of round done
    let launchSpeedReductionFactor: CGFloat = 20.0 // Speed reduction factor for difficulty balance
    let colliderSize = CGSize(width: 30, height: 30) // Basket's collider size
    var circleRadius: CGFloat = 30.0 // Radius for each circle rendered
    
    // Scrren size to dynamically place elements
    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        // Geometric plane where game objects will be rendered
        GeometryReader { geometry in
            ZStack{
                // Information about rounds, actual hour and remaining balls
                VStack{
                    // Round
                    Text("Round \(round)")
                        .font(.title)
                        .bold()
                        .foregroundStyle(Color.gray.opacity(0.3))
                        .multilineTextAlignment(.center)
                    // Date
                    Text(Date.now.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 100))
                        .bold()
                        .foregroundStyle(Color.gray.opacity(0.3))
                    // Remaining balls
                    Text("\(remainingCirclesCount) balls remaining")
                        .font(.title)
                        .bold()
                        .foregroundStyle(Color.gray.opacity(0.3))
                        .multilineTextAlignment(.center)
                    // Button to go to the next round when remaining balls are zero
                    if remainingCirclesCount == 0 {
                        Button(initialCircleCount > 1 ? "Next" : "Done") {
                            round += 1
                            initialCircleCount -= 1
                            if (initialCircleCount != 0) {
                                remainingCirclesCount = initialCircleCount
                                generateInitialCircles(in: geometry.size)
                            } else {
                                showSheet.toggle()
                            }
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .buttonBorderShape(.roundedRectangle(radius: 15))
                        .tint(Color.accentColor)
                    }
                }
                .padding(.bottom, remainingCirclesCount == 0 ? 0 : 68)
                // Basket sprite
                Image("basket")
                    .resizable()
                    .scaledToFit()
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 8.5)
                    .ignoresSafeArea()
                // It shows as much circles as the round needs
                ForEach(circles) { circle in
                    Circle()
                        .fill(Color.black)
                        .frame(width: circleRadius * 2, height: circleRadius * 2)
                        // Adds the SF Symbol of a basketball over the circle
                        .overlay(
                            Image(systemName: "basketball.fill")
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle()) // Let the image clip the circle's shape
                                .foregroundStyle(Color.accentColor)
                        )
                        .position(circle.position) // Place the shape in logical's circle position
                        // Allow drag and throwing
                        .gesture(
                            DragGesture()
                                // Drag modifier
                                .onChanged { value in
                                    moveCircle(withID: circle.id, to: value.location)
                                }
                                // Throw modifier
                                .onEnded { value in
                                    // Determine velocity and scales through reduction factor
                                    let velocity = CGSize(
                                        width: value.translation.width / (0.016 * launchSpeedReductionFactor),
                                        height: value.translation.height / (0.016 * launchSpeedReductionFactor)
                                    )
                                    // Apply velocity to the circle
                                    releaseCircle(withID: circle.id, withVelocity: velocity)
                                }
                        )
                }
            }
            .background(Color.black.ignoresSafeArea())
            // Determine and render circles once the view is loaded
            .onAppear {
                generateInitialCircles(in: geometry.size)
            }
            // Each frame updates circles' position and velocity
            .onReceive(timer) { _ in
                updateCircles(in: geometry.size)
            }
        }
    }

    // Renders the initial number of circles
    private func generateInitialCircles(in size: CGSize) {
        for _ in 0..<initialCircleCount {
            // Assign the circle a random position within some boundaries
            let randomPosition = CGPoint(
                x: CGFloat.random(in: 30...(size.width - 30)),
                y: CGFloat.random(in: (size.height * 0.65)...size.height)
            )
            let randomVelocity = CGSize.zero // The circle starts still
            circles.append(CircleModel(position: randomPosition, velocity: randomVelocity)) // Creates the logical circle
        }
        remainingCirclesCount = circles.count // Updates counter
    }

    // Updates circle's position while dragging
    private func moveCircle(withID id: UUID, to position: CGPoint) {
        if let index = circles.firstIndex(where: { $0.id == id }) {
            circles[index].position = position
            circles[index].velocity = .zero // While dragging velocity needs to be zero, otherwise the user will lose the control
        }
    }

    // Reinsert velocity once the user stops dragging
    private func releaseCircle(withID id: UUID, withVelocity velocity: CGSize) {
        if let index = circles.firstIndex(where: { $0.id == id }) {
            circles[index].velocity = velocity
        }
    }

    // Physics "engine"
    private func updateCircles(in size: CGSize) {
        // Computes for all circles
        circles = circles.compactMap { circle in
            var newCircle = circle
            // Updates position based on velocity
            newCircle.position.x += newCircle.velocity.width * 0.016
            newCircle.position.y += newCircle.velocity.height * 0.016
            // Adds gravity
            newCircle.velocity.height += 600 * 0.016
            // Bounces off bezels
            if newCircle.position.x <= circleRadius || newCircle.position.x >= size.width - circleRadius {
                newCircle.velocity.width *= -0.8
                newCircle.position.x = min(max(newCircle.position.x, circleRadius), size.width - circleRadius)
            }
            if newCircle.position.y <= circleRadius || newCircle.position.y >= size.height - circleRadius {
                newCircle.velocity.height *= -0.8
                newCircle.position.y = min(max(newCircle.position.y, circleRadius), size.height - circleRadius)
            }
            // Basket's collider shape and position
            let colliderRect = CGRect(
                x: (size.width - colliderSize.width) / 2,
                y: (size.height - colliderSize.height) / 10,
                width: colliderSize.width,
                height: colliderSize.height
            )
            // Delete circle when it collides with basket's net
            let circleFrame = CGRect(
                x: newCircle.position.x - circleRadius,
                y: newCircle.position.y - circleRadius,
                width: circleRadius * 2,
                height: circleRadius * 2
            )
            if circleFrame.intersects(colliderRect) {
                remainingCirclesCount -= 1 // Updates counter
                return nil // Removes circle
            }
            return newCircle
        }
    }
}
