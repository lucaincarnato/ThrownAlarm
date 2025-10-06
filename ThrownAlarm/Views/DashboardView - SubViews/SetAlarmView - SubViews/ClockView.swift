//
//  ClockView.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 27/09/25.
//

import SwiftUI
import AVFoundation

// Display a 24 hour clock with icons related to day and night
struct ClockView: View {
    // MARK: ATTRIBUTES
    var radius: CGFloat
    
    // MARK: VIEW BODY
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
        .accessibilityHidden(true)
    }
}
