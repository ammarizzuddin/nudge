//
//  NudgeDefaults.swift
//  Nudge
//
//  Created by Ammar Rosli on 07/10/2026.
//

import Foundation

enum NudgeDefaults {
    static let reminderLeadTime = 5.0
    static let eventGracePeriod = 5.0
    static let nudgeSound = "None"
    static let mascotAnimationMode = MascotAnimationMode.full.rawValue
    static let showCountdownInMenuBar = false
    static let hasCompletedOnboarding = false

    static func register() {
        UserDefaults.standard.register(
            defaults: [
                "reminderLeadTime": reminderLeadTime,
                "eventGracePeriod": eventGracePeriod,
                "nudgeSound": nudgeSound,
                "mascotAnimationMode": mascotAnimationMode,
                "showCountdownInMenuBar": showCountdownInMenuBar,
                "hasCompletedOnboarding": hasCompletedOnboarding
            ]
        )
    }
}
