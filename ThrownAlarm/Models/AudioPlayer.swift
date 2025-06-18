//
//  AudioPlayer.swift
//  ThrownAlarm
//
//  Created by Luca Maria Incarnato on 16/12/24.
//

import Foundation
import AVFoundation

/// Model for audio player support
class AudioPlayer: ObservableObject {
    // MARK: - Attributes
    /// Actual support where audio is played
    private var player: AVAudioPlayer?
    
    // MARK: - Public methods
    /// Plays an audio with its file name
    /// - Parameters:
    ///   - fileName: Name of the audio file
    ///   - volume: Volume of the audio
    ///   - loop: Determines if the audio should loop or not
    func playSound(_ fileName: String, volume: Float, loop: Bool = false) {
        if let player = player, player.isPlaying {
            return
        }
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "wav") else {
            print("File not found")
            return
        }
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
            if loop {
                player?.numberOfLoops = -1
            }
            player?.volume = volume
            player?.play()
        } catch {
            print("Error while playing audio file: \(error.localizedDescription)")
        }
    }
    
    /// Stops any playing sound
    func stopSound() {
        if let player = player {
            player.stop()
            player.currentTime = 0
        } else {
            print("No audio to stop")
        }
    }
}
