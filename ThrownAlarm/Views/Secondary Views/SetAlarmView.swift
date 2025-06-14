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
    @Environment(\.modelContext) private var modelContext

    @Binding var alarm: Alarm
    @Binding var setAlarm: Bool
    @Binding var isFirst: Bool
    @Binding var showAlert: Bool

    @State private var audioPlayer: AVAudioPlayer?
    @State var placeholder: Alarm

    var sounds: [String] = ["Celestial", "Enchanted", "Joy", "Mindful", "Penguin", "Plucks", "Princess", "Stardust", "Sunday", "Valley"]
    
    var body: some View {
        NavigationStack{
            VStack{
                Form{
                    Section {
                        PickerView(alarm: $placeholder)
                    }
                    Section (header: Text("Alarm options")){
                        Stepper(value: $placeholder.rounds, in: 1...10) {
                            Text("\(placeholder.rounds) rounds to wake up")
                        }
                        Picker("Alarm sound", selection: makeBinding()) {
                            ForEach(sounds, id:\.self) {
                                Text($0.description)
                                    .tag($0)
                            }
                        }
                    }
                    Button(role: .destructive){
                        modelContext.delete(alarm)
                        setAlarm.toggle()
                    } label: {
                        Text(isFirst ? "Cannot delete alarm" : "Delete")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(isFirst)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Set Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .cancellationAction){
                    Button("Cancel"){
                        stopAudio()
                        setAlarm.toggle()
                    }
                }
                ToolbarItem(placement: .confirmationAction){
                    Button("Save"){
                        alarm.copy(alarm: placeholder)
                        stopAudio()
                        alarm.setAlarm()
                        alarm.isActive = true
                        try? modelContext.save()
                        alarm.sendNotification()
                        setAlarm.toggle()
                        showAlert = true
                    }
                }
            }
            .onAppear(){
                alarm.export(alarm: placeholder)
            }
        }
    }
    
    func playAudio(for track: String?) {
        guard let track = track else { return }
        stopAudio()
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
    
    func stopAudio(){
        audioPlayer?.stop()
    }
    
    private func makeBinding() -> Binding<String> {
        Binding(
            get: { placeholder.sound },
            set: { newValue in
                placeholder.sound = newValue
                playAudio(for: newValue)
            }
        )
    }
}

private struct PickerView: View {
    @Binding var alarm: Alarm

    @State var startAngle: Angle = Angle(degrees: 0) 
    @State var endAngle: Angle = Angle(degrees: 180)
    @State var startSector: CGFloat = 0
    @State var endSector: CGFloat = 0.5
    @State var radius: CGFloat = 0.0
    
    var body: some View {
        VStack{
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
            .padding(.top, 15)
            ZStack {
                ClockView(radius: radius)
                    .accessibilityHidden(true)
                let reverse = (startSector > endSector) ? -Double((1 - startSector) * 360) : 0
                Circle()
                    .stroke(Color.black, lineWidth: 60)
                    .padding(40)
                    .accessibilityHidden(true)
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
                                    let width = geometry.size.width
                                    let height = geometry.size.height
                                    self.radius = min(width, height) / 2
                                }
                        }
                    )
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
                                alarm.sleepDuration = TimeInterval(getTimeDifference().0 * 3600 + getTimeDifference().1 * 60)
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
            Text("\(getTimeDifference().0)h:\(getTimeDifference().1)min")
                .foregroundStyle(Color.white.opacity(0.7))
                .padding(.bottom, 15)
                .accessibilityLabel("Duration: \(getTimeDifference().0) hours and \(getTimeDifference().1) minutes")
        }
        .onAppear(){
            startAngle = getAngle(from: alarm.sleepTime)
            startSector = startAngle.degrees / 360
            endAngle = getAngle(from: alarm.wakeTime)
            endSector = endAngle.degrees / 360
        }
    }
    
    func onDrag(value: DragGesture.Value, fromSlider: Bool = false){
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
    
    func getTime(angle: Angle) -> Date{
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
    
    func getAngle(from date: Date) -> Angle {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        let totalHours = Double(hour) + (Double(minute) / 60) + (Double(second) / 3600)
        let degrees = totalHours * 15
        return Angle(degrees: degrees)
    }
    
    func getTimeDifference() -> (Int, Int){
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

private struct ClockView: View {
    var radius: CGFloat
    
    var body: some View {
        ZStack{
            ForEach(1...24, id:\.self) { i in
                let d = Double(i)
                Rectangle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 2, height: i % 6 == 0 ? 15 : 5)
                    .offset(y: (radius - 80))
                    .rotationEffect(Angle(degrees: d * 15))
                let hours = [12, 15, 18, 21, 0, 3, 6, 9]
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
