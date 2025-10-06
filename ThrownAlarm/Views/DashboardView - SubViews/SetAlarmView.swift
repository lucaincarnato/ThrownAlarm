//
//  SetAlarmView.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 08/12/24.
//

import SwiftUI
import AVFoundation

struct SetAlarmView: View {
    // MARK: ATTRIBUTES
    @Environment(\.modelContext) private var modelContext
    @Binding var alarm: TAlarm
    @Binding var setAlarm: Bool
    @State private var audioPlayer: AVAudioPlayer?
    @State private var success: Bool = false
    let weekdays: [String] = ["M", "T", "W", "T", "F", "S", "S"]
    let weekvalues: [Locale.Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    
    // MARK: VIEW BODY
    var body: some View {
        NavigationStack{
            VStack{
                Form{
                    // MARK: Time Picker
                    Section {
                        PickerView(alarm: $alarm)
                    }
                    // MARK: Alarm Options
                    Section (header: Text("Alarm options")){
                        /* Unused for logistic problems/
                        HStack (alignment: .center){
                            ForEach(weekdays.indices, id: \.self) {i in
                                WeeklyRepetitionView(alarm: $alarm, day: weekdays[i], weekvalue: weekvalues[i])
                            }
                        }
                         */
                        Stepper(value: $alarm.rounds, in: 1...10) {
                            Text("\(alarm.rounds) rounds to wake up")
                        }
                        Picker("Alarm sound", selection: makeBinding()) {
                            ForEach(TAlarm.sounds, id:\.self) {
                                Text($0.description)
                                    .tag($0)
                            }
                        }
                    }
                    // MARK: Delete Button
                    Button(role: .destructive){
                        alarm.cancelAlarm()
                        modelContext.delete(alarm)
                        try? modelContext.save()
                        setAlarm.toggle()
                    } label: {
                        Text("Delete")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Set Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .sensoryFeedback(.success, trigger: success == true)
            .toolbar{
                ToolbarItem(placement: .cancellationAction, ){
                    Button(role: .cancel){
                        stopAudio()
                        setAlarm.toggle()
                        modelContext.rollback()
                        // Changes the modelContext to allow view refresh 
                        modelContext.insert(alarm)
                        modelContext.delete(alarm)
                    }
                }
                ToolbarItem(placement: .confirmationAction){
                    Button(role: .confirm){
                        success = true
                        stopAudio()
                        try? modelContext.save()
                        Task { await alarm.setAlarm() }
                        setAlarm.toggle()
                    }
                }
            }
        }
    }
    
    // MARK: PRIVATE METHODS
    // Stop any sound and plays the one selected
    private func playAudio(for track: String?) {
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
    
    // Stop audio playing
    private func stopAudio(){
        audioPlayer?.stop()
    }
    
    // Bind the audio's name to play sound as soon as it is selected
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
