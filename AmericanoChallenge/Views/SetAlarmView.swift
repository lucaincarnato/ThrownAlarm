//
//  SetAlarmView.swift
//  AmericanoChallenge
//
//  Created by Luca Maria Incarnato on 08/12/24.
//

import SwiftUI

// Allows the user to change the alarm and its settings
struct SetAlarmView: View {
    @Binding var user: Profile // Returns the info about the user profile
    @Binding var setAlarm: Bool // Binding value for the modality
    
    var body: some View {
        NavigationStack{
            VStack (alignment: .leading){
                // Form where the user will update the alarm
                Form{
                    // Section related to the start and stop hour for the alarm
                    Section {
                        PickerView(user: $user)
                    }
                    // Section related to secondary options
                    Section (header: Text("Alarm options")){
                        // Sound and haptics link TODO: RESEARCH ABOUT HOW SOUND & HAPTICS WORKS AND ACTUAL VIEW
                        NavigationLink("Sound & Haptics", destination: TimerView())
                        // Volume slider
                        HStack{
                            Image(systemName: "speaker.fill")
                            Slider(value: $user.alarm.volume, in: 0...1)
                            Image(systemName: "speaker.wave.3.fill")
                        }
                        // Snooze toggle
                        Toggle("Snooze", isOn: $user.alarm.snooze)
                    }
                }
            }
            .navigationTitle("Set Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                // Toolbar button for cancellation
                ToolbarItem(placement: .cancellationAction){
                    Button("Cancel"){
                        setAlarm.toggle()
                    }
                }
                // Toolbar button for saving and updating the alarm TODO: LINK TO THE UPDATE FUNCTION
                ToolbarItem(placement: .confirmationAction){
                    Button("Done"){
                        setAlarm.toggle()
                    }
                }
            }
        }
    }
}

// TODO: LINK ANGLE TO DATE, NOT ALLOW NEGATIVE DURATIONS
// Shows a wheel with draggable edges that allows the user to select go to sleep and wake up hours, with irl duration update
private struct PickerView: View {
    @Binding var user: Profile// Returns the info about the user profile
    @State var startAngle: Angle = Angle(degrees: 0) // Angles relative to the sleep handle
    @State var endAngle: Angle = Angle(degrees: 180) // Angles relative to the wake up handle
    @State var startSector: CGFloat = 0 // Indexes for the start of Circle's trimming
    @State var endSector: CGFloat = 0.5 // Indexes for the stop of Circle's trimming
    @State var radius: CGFloat = 0.0 // Radius of the circle
    
    var body: some View {
        VStack{
            // Live information
            HStack{
                let alarm = user.alarm
                Text(user.formatDate(alarm.sleepTime))
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(Color.white)
                Image(systemName: "arrow.forward")
                    .foregroundStyle(Color.accentColor)
                    .padding(.horizontal)
                Text(user.formatDate(alarm.wakeTime))
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(Color.white)
            }
            // Custom picker for the hour that mimics the one in the Clock app (in the Sleep section)
            .padding(.top, 15)
            ZStack {
                // Shows the 24 hours clock
                ClockView(radius: radius)
                let reverse = (startSector > endSector) ? -Double((1 - startSector) * 360) : 0 // Used to allow "negative" angles
                // Background circle
                Circle()
                    .stroke(Color.black, lineWidth: 60) // Creates a ring from the circle
                    .padding(40)
                // Actual picker body
                Circle()
                    .trim(from: (startSector > endSector) ? 0 : startSector, to: endSector + (-reverse / 360)) // Shows only the part between start and stop handles
                    .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 40, lineCap: .round, lineJoin: .round)) // Creates a ring from the circle
                    .rotationEffect(Angle(degrees: reverse)) // Doesn't allow negative angles, it just shifts the zero to give the illusion
                    .padding(40)
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
                            })
                    )
                    .sensoryFeedback(.increase, trigger: startAngle) // Haptic feedback when wheel change TODO: TRIGGER ON DATE, NOT ANGLE (TOO MANY ANGLES)
                
                
                // Immagine a destra (fine del trim)
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
                            })
                    )
                    .sensoryFeedback(.increase, trigger: endAngle) // Haptic feedback when wheel change TODO: TRIGGER ON DATE, NOT ANGLE (TOO MANY ANGLES)
            }
            .rotationEffect(Angle(degrees: -90)) // Rotate all the circle in order to show the zero not in the right part of the screen but on the top
            // Info related to the duration of the sleep
            let intDuration = Int(user.alarm.sleepDuration / 3600)
            let stringDuration = intDuration > 1 ? "\(intDuration) hours" : "\(intDuration) hour"
            Text(stringDuration)
                .foregroundStyle(Color.accentColor)
                .padding(.bottom, 15)
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
                    .fill(Color.accentColor)
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
                        .foregroundStyle(Color.accentColor)
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

#Preview {
    SetAlarmView(user: .constant(Profile()), setAlarm: .constant(true))
}