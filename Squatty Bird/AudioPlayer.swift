//
//  AudioPlayer.swift
//  Squatty Bird
//
//  Created by Leo Harnadi on 25/05/23.
//

import Foundation
import AVFoundation

class AudioPlayer {
    var BGMPlayer: AVAudioPlayer?
    var scorePlayer: AVAudioPlayer?
    var thudPlayer: AVAudioPlayer?

    func playBGM() {
        guard let url = Bundle.main.url(forResource: "backgroundMusic", withExtension: "mp3") else { return }

        do {
            BGMPlayer = try AVAudioPlayer(contentsOf: url)
            BGMPlayer?.numberOfLoops = -1
            BGMPlayer?.volume = 0.1
            BGMPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
    
    func stopBGM() {
        BGMPlayer?.stop()
    }
    
    func playMenu() {
        guard let url = Bundle.main.url(forResource: "menuMusic", withExtension: "mp3") else { return }

        do {
            BGMPlayer = try AVAudioPlayer(contentsOf: url)
            BGMPlayer?.numberOfLoops = -1
            BGMPlayer?.volume = 0.2
            BGMPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
    
    func playScore() {
        guard let url = Bundle.main.url(forResource: "score", withExtension: "mp3") else { return }

        do {
            scorePlayer = try AVAudioPlayer(contentsOf: url)
            scorePlayer?.volume = 0.05
            scorePlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
    
    func playThud() {
        guard let url = Bundle.main.url(forResource: "thud", withExtension: "mp3") else { return }

        do {
            thudPlayer = try AVAudioPlayer(contentsOf: url)
            thudPlayer?.volume = 0.1
            thudPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
    
}
