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
                            // Custom picker for the hour that mimics the one in the Clock app (in the Sleep section) TODO: ACTUAL SHAPE AND FUNCTIONALITY 
                            .padding(.top, 15)
                            Circle()
                                .foregroundStyle(Color.black)
                                .padding()
                            // Info related to the duration of the sleep
                            let intDuration = Int(user.alarm.sleepDuration / 3600)
                            let stringDuration = intDuration > 1 ? "\(intDuration) hours" : "\(intDuration) hour"
                            Text(stringDuration)
                                .foregroundStyle(Color.accentColor)
                                .padding(.bottom, 15)
                        }
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

#Preview {
    SetAlarmView(user: .constant(Profile()), setAlarm: .constant(true))
}
