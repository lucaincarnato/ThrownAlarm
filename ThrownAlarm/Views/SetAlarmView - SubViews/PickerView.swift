//
//  PickerView.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 27/09/25.
//

import SwiftUI
import AVFoundation

struct PickerView: View {
    @Binding var alarm: TAlarm

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
                    Text("\(alarm.sleepTime.hour):\(alarm.sleepTime.minute)")
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
                    Text("\(alarm.wakeTime.hour):\(alarm.wakeTime.minute)")
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
