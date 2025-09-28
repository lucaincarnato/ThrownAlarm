//
//  PickerView.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 28/09/25.
//

import SwiftUI
import AlarmKit

// Allow user to select bedtime and wake up time with a circular picker to visualize time sleeping
struct PickerView: View {
    // MARK: ATTRIBUTES
    @Binding var alarm: TAlarm
    @State private var sleepAngle: CGFloat = 0
    @State private var wakeAngle: CGFloat = .pi
    @State var radius: CGFloat = .zero
    
    // MARK: VIEW BODY 
    var body: some View {
        // Angle normalization to [0.0, 1.0] from radians
        let sleepNorm = (sleepAngle < 0 ? sleepAngle + 2 * .pi : sleepAngle) / (2 * .pi)
        let wakeNorm = (wakeAngle < 0 ? wakeAngle + 2 * .pi : wakeAngle) / (2 * .pi)
        
        VStack{
            // MARK: Sleep and Wake time visualization
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
                        Text(TAlarm.toString(alarm.sleepTime))
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
                        Text(TAlarm.toString(alarm.wakeTime))
                            .font(.largeTitle)
                            .bold()
                            .foregroundStyle(Color.white)
                    }
                }
            }
            .padding(.top, 15)
            // MARK: Picker body
            ZStack{
                ClockView(radius: radius * 1.3) // Show 24 hour clock to orient user
                // Background crown
                Circle()
                    .stroke(Color.black, lineWidth: 55)
                    .padding(40)
                    .background(
                        GeometryReader { g in
                            Color.clear.onAppear { radius = (g.size.width / 2) - 40 }
                        }
                    )
                // Normalization doesn't account for the possibility of waketime to be numerically inferior than sleeptime
                // It is needed, for that configuration, the union of a bottom crown (sleepTime to 1) and a top crown (0 to wakeTime)
                // Normal crown
                if sleepNorm < wakeNorm {
                    Circle()
                        .trim(from: sleepNorm, to: wakeNorm)
                        .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 40, lineCap: .round, lineJoin: .round))
                        .padding(40)
                }
                // Union of bottom and top crown
                else {
                    Circle()
                        .trim(from: sleepNorm, to: 1)
                        .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 40, lineCap: .butt, lineJoin: .round))
                        .padding(40)
                    Circle()
                        .trim(from: 0, to: wakeNorm)
                        .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 40, lineCap: .butt, lineJoin: .round))
                        .padding(40)
                }
                // Sleeptime handle
                Image(systemName: "bed.double.fill")
                    .foregroundStyle(Color.black)
                    .frame(width: 35, height: 35)
                    .rotationEffect(Angle(degrees: 90))
                    .background(Color.accentColor, in: Circle())
                    .offset(x: radius * cos(sleepAngle), y: radius * sin(sleepAngle))
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                onDrag(value, "sleep")
                            })
                    )
                // Waketime handle
                Image(systemName: "alarm.fill")
                    .foregroundStyle(Color.black)
                    .frame(width: 35, height: 35)
                    .rotationEffect(Angle(degrees: 90))
                    .background(Color.accentColor, in: Circle())
                    .offset(x: radius * cos(wakeAngle), y: radius * sin(wakeAngle))
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                onDrag(value, "wake")
                            })
                    )
            }
            // Set initial values from data once view is loaded
            .onAppear() {
                sleepAngle = toAngle(from: alarm.sleepTime)
                wakeAngle = toAngle(from: alarm.wakeTime)
            }
            .rotationEffect(Angle(degrees: -90))
            // MARK: Displays sleep duration
            Text("\(alarm.getDuration()/60) hours : \(alarm.getDuration()%60) minutes")
                .foregroundStyle(Color.white.opacity(0.7))
                .padding(.vertical, 10)
        }
    }
    
    // MARK: PRIVATE MEHTODS
    // Get tap position and determine angle of movement
    private func onDrag(_ value: DragGesture.Value, _ slider: String) {
        let radians = atan2(value.location.y, value.location.x)
        if slider == "sleep" {
            sleepAngle = radians
            alarm.sleepTime = toTime(from: sleepAngle)
        } else if slider == "wake" {
            wakeAngle = radians
            alarm.wakeTime = toTime(from: wakeAngle)
        }
    }
    
    // Get data and normalize it to a radians angle
    private func toAngle(from alarm: Alarm.Schedule.Relative.Time) -> CGFloat{
        let totalMinutes = CGFloat(alarm.hour * 60 + alarm.minute)
        let angle = (totalMinutes / (24 * 60)) * 2 * .pi
        return angle
    }
    
    // Get a radians angle and transforms it into usable data
    private func toTime(from angle: CGFloat) -> Alarm.Schedule.Relative.Time{
        let twoPi = CGFloat(2 * Double.pi)
        let normalizedAngle = (angle.truncatingRemainder(dividingBy: twoPi) + twoPi).truncatingRemainder(dividingBy: twoPi)
        var totalMinutes = Int(round((normalizedAngle / twoPi) * 24 * 60)) % (24 * 60)
        totalMinutes = (totalMinutes + 2) / 5 * 5
        let hour = totalMinutes / 60
        let minute = totalMinutes % 60
        return Alarm.Schedule.Relative.Time(hour: hour, minute: minute)
    }
}
