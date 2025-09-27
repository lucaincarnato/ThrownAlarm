//
//  StreakView.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 27/09/25.
//

import SwiftUI
import SwiftData
import Foundation

struct StreakView: View {
    @AppStorage("streak") private var streak: Int = 0
    @AppStorage("snoozedDays") private var snoozedDays: Int = 0
        
    var body: some View {
        VStack (alignment: .leading){
            VStack (alignment: .leading){
                HStack{
                    Image(systemName: "flame.fill")
                        .foregroundStyle(Color.green)
                        .font(.title3)
                        .accessibilityHidden(true)
                    Text("Woke up")
                        .foregroundStyle(Color.green)
                        .bold()
                        .font(.title3)
                        .accessibilityHidden(true)
                }
                HStack{
                    Text("\(streak)")
                        .font(.largeTitle)
                        .bold()
                        .accessibilityHidden(true)
                    Text(streak == 1 ? "day" : "days")
                        .font(.title3)
                        .accessibilityHidden(true)
                }
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityLabel("You successfully woke up for \(streak > 1 ? "\(streak) day" : "\(streak) days")")
            VStack (alignment: .leading){
                HStack{
                    Image(systemName: "battery.25percent")
                        .foregroundStyle(Color.red)
                        .font(.title3)
                        .accessibilityHidden(true)
                    Text("Snoozed")
                        .foregroundStyle(Color.red)
                        .bold()
                        .font(.title3)
                        .accessibilityHidden(true)
                }
                HStack {
                    Text("\(snoozedDays)")
                        .font(.largeTitle)
                        .bold()
                        .accessibilityHidden(true)
                    Text(snoozedDays == 1 ? "day" : "days")
                        .font(.title3)
                        .accessibilityHidden(true)
                }
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityLabel("You snoozed for a total of \(snoozedDays == 1 ? "\(snoozedDays) day" : "\(snoozedDays) days")")
        }
        .padding(20)
    }
}
