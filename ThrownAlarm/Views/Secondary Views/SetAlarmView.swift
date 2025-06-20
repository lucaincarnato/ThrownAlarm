//
//  SetAlarmView.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 08/12/24.
//

import SwiftUI
import FreemiumKit
import AVFoundation

struct SetAlarmView: View {
    // MARK: - Attributes
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    /// Alarm to be set up
    @Binding var alarm: Alarm
    /// Determines if it is the first alarm of the app (Freemium not unlocked yet)
    @Binding var isFirst: Bool
    /// Binding value for notification alert
    @Binding var showAlert: Bool

    @State private var audioPlayer: AVAudioPlayer?
    @State private var didBeginUndoGroup = false
    
    /// Available name sounds for alarms
    var sounds: [String] = ["Celestial", "Enchanted", "Joy", "Mindful", "Penguin", "Plucks", "Princess", "Stardust", "Sunday", "Valley"]

    // MARK: - Attributes
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    // Alarm picker section
                    Section {
                        PickerView(alarm: $alarm)
                    }
                    // Alarm options section
                    Section(header: Text("Alarm options")) {
                        // Alarm game rounds selector
                        Stepper(value: $alarm.rounds, in: 1...10) {
                            Text("\(alarm.rounds) rounds to wake up")
                        }
                        // Alarm sound picker
                        Picker("Alarm sound", selection: makeBinding()) {
                            ForEach(sounds, id: \.self) {
                                Text($0.description).tag($0)
                            }
                        }
                        // Alarm game volume slider
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Game Volume")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            HStack {
                                Image(systemName: "speaker.fill")
                                Slider(value: $alarm.volume, in: 0.0...1.0, step: 0.1)
                                Image(systemName: "speaker.wave.3.fill")
                            }
                        }
                    }
                    // Delete button
                    Button(role: .destructive) {
                        modelContext.delete(alarm)
                        try? modelContext.save()
                        dismiss()
                    } label: {
                        Text(isFirst ? "Cannot delete alarm" : "Delete")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    // Don't allow deleting alarm if it is the first of the app (Fremium not unlocked)
                    // Otherwise it will not allow the creation of any other
                    .disabled(isFirst)
                }
            }
            .navigationTitle("Set Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        // Stops previous playing audio and discard changes using SwiftData undo manager
                        audioPlayer?.stop()
                        if didBeginUndoGroup {
                            modelContext.undoManager?.endUndoGrouping()
                            modelContext.undoManager?.undo()
                        }
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Stops previous playing audio and enables the alarm
                        audioPlayer?.stop()
                        alarm.setAlarm(true)
                        if didBeginUndoGroup {
                            modelContext.undoManager?.endUndoGrouping()
                        }
                        try? modelContext.save()
                        showAlert = true // Shows the notification alert
                        dismiss()
                    }
                }
            }
            .onAppear {
                // Creates new undo group with undo manager and insert a new alarm representing the old one modified
                if modelContext.undoManager?.isUndoRegistrationEnabled == true && modelContext.undoManager?.groupingLevel == 0 {
                    modelContext.undoManager?.beginUndoGrouping()
                    didBeginUndoGroup = true
                }
                modelContext.insert(alarm)
            }
        }
    }

    // MARK: - Private methods
    /// Stops previous audio and plays the one with the specified name
    /// - Parameter track: File name string of the audio to be played
    private func playAudio(for track: String?) {
        guard let track = track else { return }
        audioPlayer?.stop()
        let trackURL = Bundle.main.url(forResource: track, withExtension: "wav")
        do {
            if let url = trackURL {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            }
        } catch {
            print("Errore nella riproduzione audio: \(error)")
        }
    }
    
    /// Binds the alarm sounds string and plays audio once changed the value
    /// - Returns: String Binding for audio string's name
    private func makeBinding() -> Binding<String> {
        Binding(
            get: { alarm.sound },
            set: { newValue in
                alarm.sound = newValue
                playAudio(for: newValue)
            }
        )
    }
}

/// Custom hour picker for alarm settings
private struct PickerView: View {
    // MARK: - Attributes
    /// Alarms which properties are changed with the picker
    @Binding var alarm: Alarm
    
    /// Angle representing the sleep hour
    @State var startAngle: Angle = Angle(degrees: 0)
    /// Angle representing the wake up hour
    @State var endAngle: Angle = Angle(degrees: 180)
    /// Point from which the sleeping sector starts (equivalent of startAngle as point)
    @State var startSector: CGFloat = 0
    /// Point where the sleeping sector ends (equivalent of endAngle as point)
    @State var endSector: CGFloat = 0.5
    /// Picker's circle's radius
    @State var radius: CGFloat = 0.0
    
    // MARK: - View
    var body: some View {
        VStack{
            // Displaying alarm's properties in text form
            HStack{
                // Sleep hour property display
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
                // Wake up hour property display
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
            .padding(.top, 15)
            // Picker to change alarm's properties
            ZStack {
                // Static clock for hour references
                ClockView(radius: radius)
                    .accessibilityHidden(true)
                let reverse = (startSector > endSector) ? -Double((1 - startSector) * 360) : 0
                // Background element
                Circle()
                    .stroke(Color.black, lineWidth: 60)
                    .padding(40)
                    .accessibilityHidden(true)
                // Circular sector representing the sleep duration (from sleep hour to wake hour in angles)
                Circle()
                    .trim(from: (startSector > endSector) ? 0 : startSector, to: endSector + (-reverse / 360))
                    .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 40, lineCap: .round, lineJoin: .round))
                    .rotationEffect(Angle(degrees: reverse))
                    .padding(40)
                    .accessibilityHidden(true)
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    // Get component sizes and set picker's radius to be the minimum among the two sizes
                                    let width = geometry.size.width
                                    let height = geometry.size.height
                                    self.radius = min(width, height) / 2
                                }
                        }
                    )
                // Handle for sleep hour
                Image(systemName: "bed.double.fill")
                    .foregroundStyle(Color.black)
                    .frame(width: 35, height: 35)
                    .rotationEffect(Angle(degrees: 90))
                    .background(Color.accentColor, in: Circle())
                    .offset(x: (radius - 40) * cos(startAngle.radians), y: (radius - 40) * sin(startAngle.radians))
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                onDrag(value: value, fromSlider: true)
                                alarm.sleepTime = getTime(angle: startAngle)
                            })
                    )
                    .accessibilityLabel("Bedtime")
                    .accessibilityValue("\(getTime(angle: startAngle).formatted(date: .omitted, time: .shortened))")
                    .accessibilityAddTraits(.isButton)
                    .accessibilityRemoveTraits(.isImage)
                    .accessibilityAdjustableAction { direction in
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
                    .sensoryFeedback(.increase, trigger: getTime(angle: startAngle))
                // Handle for wake up hour
                Image(systemName: "alarm.fill")
                    .foregroundStyle(Color.black)
                    .frame(width: 35, height: 35)
                    .rotationEffect(Angle(degrees: 90))
                    .background(Color.accentColor, in: Circle())
                    .offset(x: (radius - 40) * cos(endAngle.radians), y: (radius - 40) * sin(endAngle.radians))
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                onDrag(value: value)
                                alarm.wakeTime = getTime(angle: endAngle)
                            })
                    )
                    .accessibilityLabel("Wake up")
                    .accessibilityValue("\(getTime(angle: endAngle).formatted(date: .omitted, time: .shortened))")
                    .accessibilityAddTraits(.isButton)
                    .accessibilityRemoveTraits(.isImage)
                    .accessibilityAdjustableAction { direction in
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
                    .sensoryFeedback(.increase, trigger: getTime(angle: endAngle))
            }
            .rotationEffect(Angle(degrees: -90))
            // Sleep duration information display
            Text("\(getTimeDifference().0)h:\(getTimeDifference().1)min")
                .foregroundStyle(Color.white.opacity(0.7))
                .padding(.bottom, 15)
                .accessibilityLabel("Duration: \(getTimeDifference().0) hours and \(getTimeDifference().1) minutes")
        }
        .onAppear(){
            // Binds alarm's data to UI elements
            startAngle = getAngle(from: alarm.sleepTime)
            startSector = startAngle.degrees / 360
            endAngle = getAngle(from: alarm.wakeTime)
            endSector = endAngle.degrees / 360
        }
    }
    
    // MARK: - Private methods
    /// Updates Picker's UI based on user drag
    /// - Parameters:
    ///   - value: Value got from drag gesture
    ///   - fromSlider: Determines if the Drag gesture comes from accessibility function or not
    private func onDrag(value: DragGesture.Value, fromSlider: Bool = false){
        let vector = CGVector(dx: value.location.x, dy: value.location.y)
        let radians = atan2(vector.dy, vector.dx)
        var angle = radians * 180 / Double.pi
        if angle < 0 {angle = angle + 360}
        let progress = angle / 360
        if fromSlider{
            self.startAngle = Angle(degrees: angle)
            self.startSector = progress
        } else {
            self.endAngle = Angle(degrees: angle)
            self.endSector = progress
        }
    }
    
    /// Get Date time from Picker's handle angle
    /// - Parameter angle: Angle from which get the time
    /// - Returns: Date time corresponding to input Angle
    private func getTime(angle: Angle) -> Date{
        let progress = angle.degrees / 15
        let hours = Int(progress)
        let remainder = (progress.truncatingRemainder(dividingBy: 1) * 12).rounded()
        var minutes = remainder * 5
        minutes = (minutes > 55 ? 55 : minutes)
        let now = Date.now
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
        components.hour = hours
        components.minute = Int(minutes)
        components.second = 0
        let targetDate = calendar.date(from: components) ?? now
        if targetDate <= now {
            return calendar.date(byAdding: .day, value: 1, to: targetDate) ?? now
        }
        return targetDate
    }
    
    /// Get Picker's handle angle from date input
    /// - Parameter date: Date from which generate Picker's handle angle
    /// - Returns: Angle corresponding to input Date
    private func getAngle(from date: Date) -> Angle {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        let totalHours = Double(hour) + (Double(minute) / 60) + (Double(second) / 3600)
        let degrees = totalHours * 15
        return Angle(degrees: degrees)
    }
    
    /// Get Date time from Picker's handles angles and get hour and minutes of sleep
    /// - Returns: Array of hours and minutes of sleep
    private func getTimeDifference() -> (Int, Int){
        let calendar = Calendar.current
        var results = calendar.dateComponents([.hour, .minute], from: getTime(angle: startAngle), to: getTime(angle: endAngle))
        if (results.hour! < 0) {
            results.hour = (results.hour!) + 24
        }
        if (results.minute! < 0){
            if (results.hour! != 0) {results.hour! -= 1}
            results.minute = (results.minute!) + 60
        }
        return (results.hour ?? 0, results.minute ?? 0)
    }
}

/// Creates a static clock in the 24 hours format
private struct ClockView: View {
    // MARK: - Attributes
    /// Radius of  clock's circle
    var radius: CGFloat
    
    // MARK: - View
    var body: some View {
        ZStack{
            // Iterates for the 24 hours indicators
            ForEach(1...24, id:\.self) { i in
                let d = Double(i)
                Rectangle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 2, height: i % 6 == 0 ? 15 : 5)
                    .offset(y: (radius - 80))
                    .rotationEffect(Angle(degrees: d * 15))
                // Get the number for only the multiple of 3 hours
                let hours = [12, 15, 18, 21, 0, 3, 6, 9]
                // Iterates for the hour number
                ForEach(hours.indices, id:\.self){ i in
                    let d = Double(i)
                    Text("\(hours[i])")
                        .bold()
                        .font(.subheadline)
                        .foregroundStyle(Color.white)
                        .rotationEffect(Angle(degrees: d * -45))
                        .offset(y: (radius - 100))
                        .rotationEffect(Angle(degrees: d * 45))
                }
            }
            // Shows images for daylight hours and night hours
            Image(systemName: "moon.haze.fill")
                .foregroundStyle(Color.cyan)
                .offset(y: (-radius + 130))
            Image(systemName: "sun.horizon.fill")
                .foregroundStyle(Color.yellow)
                .offset(y: (radius - 130))
        }
        .rotationEffect(Angle(degrees: 90))
    }
}
