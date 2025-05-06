//
//  SetAlarmView.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 08/12/24.
//

import SwiftUI
import FreemiumKit
import AVFoundation

// Allows the user to change the alarm and its settings
struct SetAlarmView: View {
    @Environment(\.modelContext) private var modelContext // Context needed for SwiftData operations

    @Binding var alarm: Alarm // Returns the info about the user profile
    @Binding var setAlarm: Bool // Binding value for the modality
    @Binding var isFirst: Bool
    @Binding var showAlert: Bool // MARK: BOOLEAN FOR THE SILENT AND FOCUS MODE ALERT, TO BE REMOVED

    @State private var audioPlayer: AVAudioPlayer?
    @State var placeholder: Alarm // Placeholder to not save date on cancel

    // Available sound's names
    var sounds: [String] = ["Celestial", "Enchanted", "Joy", "Mindful", "Penguin", "Plucks", "Princess", "Stardust", "Sunday", "Valley"]
    
    var body: some View {
        NavigationStack{
            VStack{
                // Form where the user will update the alarm
                Form{
                    // Section related to the start and stop hour for the alarm
                    Section {
                        PickerView(alarm: $placeholder)
                    }
                    // Section related to secondary options
                    Section (header: Text("Alarm options")){
                        Stepper(value: $placeholder.rounds, in: 1...10) {
                            Text("\(placeholder.rounds) rounds to wake up")
                        }
                        // Sound picker
                        Picker("Alarm sound", selection: makeBinding()) {
                            ForEach(sounds, id:\.self) {
                                Text($0.description)
                                    .tag($0)
                            }
                        }
                    }
                    // Delete button and close the modal
                    Button(role: .destructive){
                        modelContext.delete(alarm)
                        setAlarm.toggle()
                    } label: {
                        Text(isFirst ? "Cannot delete alarm" : "Delete")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(isFirst) // Disables if it is the first free alarm
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Set Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                // Toolbar button for cancellation
                ToolbarItem(placement: .cancellationAction){
                    Button("Cancel"){
                        stopAudio() // Stops all the sound when the user exits from modal
                        setAlarm.toggle()
                    }
                }
                // Toolbar button for saving and updating the alarm
                ToolbarItem(placement: .confirmationAction){
                    Button("Save"){
                        alarm.copy(alarm: placeholder) // Saves the data only when user is done, not when cancels
                        stopAudio() // Stops all the sound when the user exits from modal
                        alarm.setDuration()
                        alarm.setAlarm() // Set the date to not create conflicts with past dates
                        alarm.isActive = true // Activate alarm
                        try? modelContext.save()
                        alarm.sendNotification() // Schedule the notifications when the user changes the alarm
                        setAlarm.toggle()
                        showAlert = true // MARK: TOGGLE FOR THE ALERT, TO BE REMOVED
                    }
                }
            }
            .onAppear(){
                // Initialize the placeholder with real values
                alarm.export(alarm: placeholder)
            }
        }
    }
    
    // Allows playing music inside the app, used to preview notification sound and in minigame
    func playAudio(for track: String?) {
        guard let track = track else { return }
        stopAudio() // Stops any audio before
        // Get url from track
        let trackURL = Bundle.main.url(forResource: track, withExtension: "wav")
        do {
            // Create audio player and play
            if let url = trackURL {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            }
        } catch {
            print("Errore nella riproduzione audio: \(error)")
        }
    }
    
    // Stops any previous audio
    func stopAudio(){
        audioPlayer?.stop()
    }
    
    // Assign new sound to user and preview it, returnign binding for the picker
    private func makeBinding() -> Binding<String> {
        Binding(
            get: { placeholder.sound },
            set: { newValue in
                placeholder.sound = newValue
                playAudio(for: newValue) // Trigger playback on every selection
            }
        )
    }
}

// Shows a wheel with draggable edges that allows the user to select go to sleep and wake up hours, with irl duration update
private struct PickerView: View {
    @Binding var alarm: Alarm// Returns the info about the user profile

    @State var startAngle: Angle = Angle(degrees: 0) // Angles relative to the sleep handle
    @State var endAngle: Angle = Angle(degrees: 180) // Angles relative to the wake up handle
    @State var startSector: CGFloat = 0 // Indexes for the start of Circle's trimming
    @State var endSector: CGFloat = 0.5 // Indexes for the stop of Circle's trimming
    @State var radius: CGFloat = 0.0 // Radius of the circle
    
    var body: some View {
        VStack{
            // Live information
            HStack{
                VStack{
                    HStack{
                        Image(systemName: "bed.double.fill")
                            .foregroundStyle(Color.white.opacity(0.5))
                            .accessibilityHidden(true)
                        Text("BEDTIME")
                            .foregroundStyle(Color.white.opacity(0.5))
                            .font(.subheadline)
                            .bold()
                    }
                    Text(alarm.sleepTime.formatted(date: .omitted, time: .shortened))
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(Color.white)
                }
                Image(systemName: "arrow.forward")
                    .foregroundStyle(Color.accentColor)
                    .padding(.horizontal)
                VStack{
                    HStack{
                        Image(systemName: "alarm.fill")
                            .foregroundStyle(Color.white.opacity(0.5))
                            .accessibilityHidden(true)
                        Text("WAKE UP")
                            .foregroundStyle(Color.white.opacity(0.5))
                            .font(.subheadline)
                            .bold()
                    }
                    Text(alarm.wakeTime.formatted(date: .omitted, time: .shortened))
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(Color.white)
                }
            }
            .accessibilityElement(children: .combine)
            // Custom picker for the hour that mimics the one in the Clock app (in the Sleep section)
            .padding(.top, 15)
            ZStack {
                // Shows the 24 hours clock
                ClockView(radius: radius)
                    .accessibilityHidden(true)
                let reverse = (startSector > endSector) ? -Double((1 - startSector) * 360) : 0 // Used to allow "negative" angles
                // Background circle
                Circle()
                    .stroke(Color.black, lineWidth: 60) // Creates a ring from the circle
                    .padding(40)
                    .accessibilityHidden(true)
                // Actual picker body
                Circle()
                    .trim(from: (startSector > endSector) ? 0 : startSector, to: endSector + (-reverse / 360)) // Shows only the part between start and stop handles
                    .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 40, lineCap: .round, lineJoin: .round)) // Creates a ring from the circle
                    .rotationEffect(Angle(degrees: reverse)) // Doesn't allow negative angles, it just shifts the zero to give the illusion
                    .padding(40)
                    .accessibilityHidden(true)
                // Returns circle's radius
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    // Calcolo del raggio
                                    let width = geometry.size.width
                                    let height = geometry.size.height
                                    self.radius = min(width, height) / 2
                                }
                        }
                    )
                // Sleep handle
                Image(systemName: "bed.double.fill")
                    .foregroundStyle(Color.black)
                    .frame(width: 35, height: 35)
                    .rotationEffect(Angle(degrees: 90)) // Rotate in order to appear straight from user's perspective
                    .background(Color.accentColor, in: Circle())
                    .offset(x: (radius - 40) * cos(startAngle.radians), y: (radius - 40) * sin(startAngle.radians)) // Allow the alignment to Circle and the shift once moved
                // Handle movement logic
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                onDrag(value: value, fromSlider: true)
                                alarm.sleepTime = getTime(angle: startAngle) // Update user's info
                            })
                    )
                    .accessibilityLabel("Bedtime")
                    .accessibilityValue("\(getTime(angle: startAngle).formatted(date: .omitted, time: .shortened))")
                    .accessibilityAddTraits(.isButton)
                    .accessibilityRemoveTraits(.isImage)
                    .accessibilityAdjustableAction { direction in // Swipe up increments, swipe down decrements
                        switch direction {
                        case .increment:
                            self.startAngle.degrees += 1.25
                            self.startSector += 1.25 / 360
                            alarm.sleepTime = getTime(angle: startAngle)
                            break
                        case .decrement:
                            self.startAngle.degrees -= 1.25
                            self.startSector -= 1.25 / 360
                            alarm.sleepTime = getTime(angle: startAngle)
                            break
                        @unknown default:
                            break
                        }
                    }
                    .sensoryFeedback(.increase, trigger: getTime(angle: startAngle)) // Haptic feedback when wheel change
                // Wake up handle
                Image(systemName: "alarm.fill")
                    .foregroundStyle(Color.black)
                    .frame(width: 35, height: 35)
                    .rotationEffect(Angle(degrees: 90)) // Rotate in order to appear straight from user's perspective
                    .background(Color.accentColor, in: Circle())
                    .offset(x: (radius - 40) * cos(endAngle.radians), y: (radius - 40) * sin(endAngle.radians)) // Allow the alignment to Circle and the shift once moved
                // Handle movement logic
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                onDrag(value: value)
                                alarm.wakeTime = getTime(angle: endAngle) // Update user's info
                                alarm.sleepDuration = TimeInterval(getTimeDifference().0 * 3600 + getTimeDifference().1 * 60)
                            })
                    )
                    .accessibilityLabel("Wake up")
                    .accessibilityValue("\(getTime(angle: endAngle).formatted(date: .omitted, time: .shortened))")
                    .accessibilityAddTraits(.isButton)
                    .accessibilityRemoveTraits(.isImage)
                    .accessibilityAdjustableAction { direction in // Swipe up increments, swipe down decrements
                        switch direction {
                        case .increment:
                            self.endAngle.degrees += 1.25
                            self.endSector += 1.25 / 360
                            alarm.wakeTime = getTime(angle: endAngle)
                            break
                        case .decrement:
                            self.endAngle.degrees -= 1.25
                            self.endSector -= 1.25 / 360
                            alarm.wakeTime = getTime(angle: endAngle)
                            break
                        @unknown default:
                            break
                        }
                    }
                    .sensoryFeedback(.increase, trigger: getTime(angle: endAngle)) // Haptic feedback when wheel change
            }
            .rotationEffect(Angle(degrees: -90)) // Rotate all the circle in order to show the zero not in the right part of the screen but on the top
            // Info related to the duration of the sleep
            Text("\(getTimeDifference().0)h:\(getTimeDifference().1)min")
                .foregroundStyle(Color.white.opacity(0.7))
                .padding(.bottom, 15)
                .accessibilityLabel("Duration: \(getTimeDifference().0) hours and \(getTimeDifference().1) minutes")
        }
        // When the view appears it changes the handles to match user previous info
        .onAppear(){
            startAngle = getAngle(from: alarm.sleepTime)
            startSector = startAngle.degrees / 360
            endAngle = getAngle(from: alarm.wakeTime)
            endSector = endAngle.degrees / 360
        }
    }
    
    // Changes angles and trimming indexes according to where the user is moving the image
    func onDrag(value: DragGesture.Value, fromSlider: Bool = false){
        let vector = CGVector(dx: value.location.x, dy: value.location.y) // Get vector from user's pointer
        let radians = atan2(vector.dy, vector.dx) // Get angle of movement
        var angle = radians * 180 / Double.pi // Get angle in degrees from angle in radians
        if angle < 0 {angle = angle + 360}
        let progress = angle / 360 // Normalize the angle to conform to trimming index
        // Update angle and trimming index only to the handle selected (true for the sleep handle and false for the wake up one
        if fromSlider{
            self.startAngle = Angle(degrees: angle)
            self.startSector = progress
        } else {
            self.endAngle = Angle(degrees: angle)
            self.endSector = progress
        }
    }
    
    // Return the corresponding date to the angle user selected
    func getTime(angle: Angle) -> Date{
        let progress = angle.degrees / 15 // 15 is the angle for an hour
        let hours = Int(progress)
        let remainder = (progress.truncatingRemainder(dividingBy: 1) * 12).rounded() // Creates a minute step with five as base
        var minutes = remainder * 5
        minutes = (minutes > 55 ? 55 : minutes) // Don't allow approximation over 55
        let now = Date.now
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        // Build the date with the calendar component of the desired day
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
        components.hour = hours
        components.minute = Int(minutes)
        components.second = 0
        // Get the built date
        let targetDate = calendar.date(from: components) ?? now
        // If built date is in the past, add a day
        if targetDate <= now {
            return calendar.date(byAdding: .day, value: 1, to: targetDate) ?? now
        }
        return targetDate
    }
    
    // Returns angle from date for initialization
    func getAngle(from date: Date) -> Angle {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        // Date in hours
        let totalHours = Double(hour) + (Double(minute) / 60) + (Double(second) / 3600)
        // Degrees conversion
        let degrees = totalHours * 15 // 15 degrees per hour
        return Angle(degrees: degrees)
    }
    
    // Returns the actual difference between wake up and sleep time
    func getTimeDifference() -> (Int, Int){
        let calendar = Calendar.current
        // Get actual difference in integers
        var results = calendar.dateComponents([.hour, .minute], from: getTime(angle: startAngle), to: getTime(angle: endAngle))
        // Avoid negative hours
        if (results.hour! < 0) {
            results.hour = (results.hour!) + 24
        }
        // Avoid negative minutes
        if (results.minute! < 0){
            if (results.hour! != 0) {results.hour! -= 1}
            results.minute = (results.minute!) + 60
        }
        return (results.hour ?? 0, results.minute ?? 0)
    }
}

// Shows a 24 hours clock to give the user some reference while choosing the time for the alarm
private struct ClockView: View {
    var radius: CGFloat // Radius of the circle the clock will be inserted in
    
    var body: some View {
        ZStack{
            // Creates the 24 marks for the hours
            ForEach(1...24, id:\.self) { i in
                let d = Double(i)
                // Arrange them according to a common clock
                Rectangle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 2, height: i % 6 == 0 ? 15 : 5) // 0, 6, 12 and 18 will be a little bit bigger for aesthetics
                    .offset(y: (radius - 80)) // Moved to the center
                    .rotationEffect(Angle(degrees: d * 15)) // Rotated to be normal to the circle
                // Shows for each 3 marks the relative hour on the clock
                let hours = [12, 15, 18, 21, 0, 3, 6, 9]
                ForEach(hours.indices, id:\.self){ i in
                    let d = Double(i)
                    // Arrange them according to a common clock
                    Text("\(hours[i])")
                        .bold()
                        .font(.subheadline)
                        .foregroundStyle(Color.white)
                        .rotationEffect(Angle(degrees: d * -45)) // Rotated to be close to the relative mark
                        .offset(y: (radius - 100)) // Moved to the center
                        .rotationEffect(Angle(degrees: d * 45)) // Rotated to be straight from user's perspective
                }
            }
            // Sun and moon icons to communicate night and day
            Image(systemName: "moon.haze.fill")
                .foregroundStyle(Color.cyan)
                .offset(y: (-radius + 130)) // Moved to the center
            Image(systemName: "sun.horizon.fill")
                .foregroundStyle(Color.yellow)
                .offset(y: (radius - 130)) // Moved to the center
        }
        .rotationEffect(Angle(degrees: 90)) // Necessary because the parent will be -90 degrees rotated
    }
}
