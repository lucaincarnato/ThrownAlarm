//
//  SetAlarmView.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 08/12/24.
//

import SwiftUI
import AVFoundation

struct SetAlarmView: View {
    @Environment(\.modelContext) private var modelContext

    @Binding var alarm: TAlarm
    @Binding var setAlarm: Bool

    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        NavigationStack{
            VStack{
                Form{
                    Section {
                        //PickerView(alarm: $alarm)
                    }
                    Section (header: Text("Alarm options")){
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
                    Button(role: .destructive){
                        modelContext.delete(alarm)
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
            .toolbar{
                ToolbarItem(placement: .cancellationAction){
                    Button("Cancel"){
                        stopAudio()
                        setAlarm.toggle()
                    }
                }
                ToolbarItem(placement: .confirmationAction){
                    Button("Save"){
                        stopAudio()
                        alarm.active = true
                        try? modelContext.save()
                        Task { await alarm.setAlarm() }
                        setAlarm.toggle()
                    }
                }
            }
        }
    }
    
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
    
    private func stopAudio(){
        audioPlayer?.stop()
    }
    
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
