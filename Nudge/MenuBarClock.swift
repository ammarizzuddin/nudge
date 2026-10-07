//
//  MenuBarClock.swift
//  Nudge
//
//  Created by Ammar Rosli on 07/10/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class MenuBarClock {
    private(set) var now = Date()

    private var timer: Timer?

    func start() {
        guard timer == nil else {
            return
        }

        timer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.now = Date()
            }
        }
    }
}
