//
//  Globals.swift
//  Testing AR
//
//  Created by Leo Harnadi on 23/05/23.
//

import Foundation
import UIKit
import CoreHaptics

var score: Int = 0
var highScore: Int = 0

var backgroundFont: String = "8-bit Arcade Out"
var foregroundFont: String = "8-bit Arcade In"

var player: CHHapticPatternPlayer?

var audioPlayer = AudioPlayer()

// Haptics

var hapticEngine: CHHapticEngine?

func triggerHapticFeedback(with pattern: CHHapticPattern) {
    do {
        player = try hapticEngine?.makePlayer(with: pattern)
        try player?.start(atTime: CHHapticTimeImmediate)
    } catch let error {
        print("Failed to play haptic pattern: \(error)")
    }
}

func createHapticEvent(isLose: Bool) -> CHHapticEvent {
    let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
    let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
    let duration: TimeInterval = 1
    let event: CHHapticEvent
    
    if isLose {
        event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity,sharpness], relativeTime: 0, duration: duration)
    } else {
        event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity,sharpness], relativeTime: 0)
    }
    
    return event
}

func createHapticPattern(isLose: Bool) -> CHHapticPattern {
    let event = createHapticEvent(isLose: isLose)
    let pattern = try! CHHapticPattern(events: [event], parameters: [])
    return pattern
}
