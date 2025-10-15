//
//  AlarmGameView.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 11/12/24.
//

import SwiftUI
import SwiftData

struct CircleModel: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGSize
}

struct AlarmGameView: View {
    // MARK: ATTRIBUTES
    @Query(sort: \TNight.date, order: .forward) private var backtrack: [TNight]
    @Environment(\.modelContext) private var modelContext
    @Binding var alarm: TAlarm
    @AppStorage("AlarmGame") private var alarmGame: Bool = false
    @AppStorage("ThrowType") var throwType: String = "Basket"
    // Tracking variables
    @State private var tracked: Track = .notTracked
    @State private var valueTrack: Bool = false
    // Internal state variables
    @State var bouncing: Bool = false
    @State var circles: [CircleModel] = []
    @State var timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    @State var remainingCirclesCount: Int = 0
    @State var initialCircleCount = 1
    @State var rounds : Int
    @State private var holdingCircle: Bool = false
    var player: AudioPlayer = AudioPlayer()
    let launchSpeedReductionFactor: CGFloat = 20.0
    let colliderSize = CGSize(width: 30, height: 30)
    var circleRadius: CGFloat = 30.0
    
    // MARK: VIEW BODY
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                // MARK: Heads Up Display Informations
                VStack{
                    Text("\(rounds) rounds remaining")
                        .font(.title)
                        .bold()
                        .foregroundStyle(Color.gray.opacity(0.3))
                        .multilineTextAlignment(.center)
                    Text(Date.now.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 100))
                        .bold()
                        .foregroundStyle(Color.gray.opacity(0.3))
                    Text("\(remainingCirclesCount) balls remaining")
                        .font(.title)
                        .bold()
                        .foregroundStyle(Color.gray.opacity(0.3))
                        .multilineTextAlignment(.center)
                    if remainingCirclesCount == 0 {
                        Button(rounds == 1 ? "Done" : "Next") {
                            changeRound(in: geometry.size)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .buttonBorderShape(.roundedRectangle(radius: 15))
                        .tint(Color.accentColor)
                    }
                }
                .padding(.bottom, remainingCirclesCount == 0 ? 0 : 68)
                // MARK: Target
                Image(throwType)
                    .resizable()
                    .scaledToFit()
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 8.5)
                    .ignoresSafeArea()
                    .accessibilityHidden(true)
                // MARK: Tools
                ForEach(circles) { circle in
                    Circle()
                        .fill(Color.black)
                        .frame(width: circleRadius * 2, height: circleRadius * 2)
                        .overlay(
                            Image("\(throwType)User")
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                                .foregroundStyle(Color.accentColor)
                        )
                        .position(circle.position)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    moveCircle(withID: circle.id, to: value.location)
                                    holdingCircle.toggle()
                                }
                                .onEnded { value in
                                    let velocity = CGSize(
                                        width: 1.5 * value.translation.width / (0.016 * launchSpeedReductionFactor),
                                        height: 1.5 * value.translation.height / (0.016 * launchSpeedReductionFactor)
                                    )
                                    releaseCircle(withID: circle.id, withVelocity: velocity)
                                }
                        )
                        .accessibilityLabel("Ball")
                        .accessibilityRemoveTraits(.isImage)
                        .accessibilityAddTraits(.isButton)
                        .accessibilityAdjustableAction { direction in
                            if (direction == .increment) {accessibleRemove(circle, geometry.size)}
                        }
                }
                .sensoryFeedback(.impact(weight: .medium, intensity: 0.6), trigger: holdingCircle)
                .sensoryFeedback(.success, trigger: remainingCirclesCount)
            }
            .sensoryFeedback(.warning, trigger: bouncing)
            .background(Color.black.ignoresSafeArea())
            .task {
                startGame()
                player.playSound(alarm.sound, loop: true)
                generateInitialCircles(in: geometry.size)
            }
            .onReceive(timer) { _ in
                updateCircles(in: geometry.size)
            }
        }
        .onAppear(){

        }
    }
    
    // MARK: PRIVATE METHODS
    // Generate circles at the start of the game with random position at the bottom of the screen
    private func generateInitialCircles(in size: CGSize) {
        for _ in 0..<initialCircleCount {
            let randomPosition = CGPoint(
                x: CGFloat.random(in: 30...(size.width - 30)),
                y: CGFloat.random(in: (size.height * 0.65)...size.height)
            )
            let randomVelocity = CGSize.zero
            circles.append(CircleModel(position: randomPosition, velocity: randomVelocity))
        }
        remainingCirclesCount = circles.count
    }
    
    // Move selected circle and sets its velocity to zero (user is holding the circle, it has no speed)
    private func moveCircle(withID id: UUID, to position: CGPoint) {
        if let index = circles.firstIndex(where: { $0.id == id }) {
            circles[index].position = position
            circles[index].velocity = .zero
        }
    }
    
    // Apply velocity when user release circle
    private func releaseCircle(withID id: UUID, withVelocity velocity: CGSize) {
        if let index = circles.firstIndex(where: { $0.id == id }) {
            circles[index].velocity = velocity
        }
    }
    
    // Apply physics
    private func updateCircles(in size: CGSize) {
        circles = circles.compactMap { circle in
            var newCircle = circle
            newCircle.position.x += newCircle.velocity.width * 0.016
            newCircle.position.y += newCircle.velocity.height * 0.016
            newCircle.velocity.height += 600 * 0.016
            if newCircle.position.x <= circleRadius || newCircle.position.x >= size.width - circleRadius {
                newCircle.velocity.width *= -0.8
                newCircle.position.x = min(max(newCircle.position.x, circleRadius), size.width - circleRadius)
                bouncing.toggle()
            }
            if newCircle.position.y <= circleRadius || newCircle.position.y >= size.height - circleRadius {
                newCircle.velocity.height *= -0.8
                newCircle.position.y = min(max(newCircle.position.y, circleRadius), size.height - circleRadius)
            }
            let colliderRect = CGRect(
                x: (size.width - colliderSize.width) / 2,
                y: (size.height - colliderSize.height) / 10,
                width: colliderSize.width,
                height: colliderSize.height
            )
            let circleFrame = CGRect(
                x: newCircle.position.x - circleRadius,
                y: newCircle.position.y - circleRadius,
                width: circleRadius * 2,
                height: circleRadius * 2
            )
            if circleFrame.intersects(colliderRect) {
                remainingCirclesCount -= 1
                return nil
            }
            return newCircle
        }
    }
    
    // Sets up the game with alarm options and hour lookup for streak state
    private func startGame(){
        valueTrack = !alarm.wokeWithin(seconds: 55) // User has 55 seconds to start the game otherwise it will count as snooze (value of the night)
        // Tracks previous tracking of current day
        if TNight.alreadyTracked(in: backtrack) {
            if backtrack.last!.snoozed { tracked = .trackedSnoozed }
            else { tracked = .trackedNotSnoozed}
        } else {
            tracked = .notTracked
            modelContext.insert(TNight(date: Date.now, snoozed: true)) // Insert new record if current day was not tracked
        }
        try? modelContext.save()
    }
    
    // Called once the user clears all the rounds of the game and checks tracking to update streak
    private func recordNight() {
        // If night was never tracked or if it was but user didn't snooze, the value of the night is passed
        if tracked == .notTracked || tracked == .trackedNotSnoozed {
            backtrack.last!.snoozed = valueTrack
        }
        try? modelContext.save()
    }
    
    // Called every time user clears the number of circles in the scene
    private func changeRound(in size: CGSize){
        rounds -= 1
        initialCircleCount += 1
        if (rounds == 0) {
            player.stopSound()
            recordNight()
            alarm.cancelAlarm()
            alarmGame = false
        } else {
            remainingCirclesCount = initialCircleCount
            generateInitialCircles(in: size)
        }
    }
    
    // Ball removal function for VoiceOver
    private func accessibleRemove(_ circle: CircleModel, _ size: CGSize){
        moveCircle(withID: circle.id, to: CGPoint(x: (size.width - colliderSize.width) / 2, y: (size.height - colliderSize.height) / 10))
    }
}

private enum Track {
    case notTracked
    case trackedSnoozed
    case trackedNotSnoozed
}
