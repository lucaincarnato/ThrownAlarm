//
//  AudioPlayer.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 16/12/24.
//

import Foundation
import AVFoundation

// Allows playing music inside the app, used to preview notification sound and in minigame
class AudioPlayer: ObservableObject {
    private var player: AVAudioPlayer?
    
    // Play the audio
    func playSound(_ fileName: String, loop: Bool = false) {
        // If audio is already reproducing, do nothing
        if let player = player, player.isPlaying {
            return
        }
        // Set URL from filename
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "wav") else {
            print("File not found")
            return
        }
        // Play audio
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
            // Plays the audio in loop if the call allows it
            if loop {
                player?.numberOfLoops = -1 // Infinite loop
            }
            player?.volume = 0.1 // Lowers the volume for better waking up experience
            player?.play()
        } catch {
            print("Error while playing audio file: \(error.localizedDescription)")
        }
    }
    
    // Stop the audio
    func stopSound() {
        if let player = player {
            player.stop()
            player.currentTime = 0 // Comes back to the start of the file
        } else {
            print("No audio to stop")
        }
    }
}
