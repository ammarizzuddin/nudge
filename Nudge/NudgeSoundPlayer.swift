//
//  NudgeSoundPlayer.swift
//  Nudge
//
//  Created by Ammar Rosli on 07/10/2026.
//

import AppKit
import Foundation

enum NudgeSoundPlayer {

    static func playSelectedSound() {
        let soundName = UserDefaults.standard.string(
            forKey: "nudgeSound"
        ) ?? "None"

        guard soundName != "None" else {
            return
        }

        NSSound(
            named: NSSound.Name(soundName)
        )?.play()
    }
}
