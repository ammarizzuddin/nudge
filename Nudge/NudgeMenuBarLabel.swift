//
//  NudgeMenuBarLabel.swift
//  Nudge
//
//  Created by Ammar Rosli on 07/10/2026.
//

import EventKit
import SwiftUI

struct NudgeMenuBarLabel: View {
    let calendarManager: CalendarManager
    let clock: MenuBarClock

    @AppStorage("showCountdownInMenuBar")
    private var showCountdownInMenuBar = false

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "bell.badge")

            if showCountdownInMenuBar,
               let event = calendarManager.nextEvent {
                Text(
                    countdownText(
                        for: event,
                        at: clock.now
                    )
                )
                .monospacedDigit()
            }
        }
    }

    private func countdownText(
        for event: EKEvent,
        at date: Date
    ) -> String {
        let remaining = event.startDate.timeIntervalSince(date)

        if remaining <= 0 {
            return "Now"
        }

        let totalSeconds = Int(remaining)
        let minutes = totalSeconds / 60

        if minutes < 1 {
            return "<1m"
        }

        if minutes < 60 {
            return "\(minutes)m"
        }

        let hours = minutes / 60

        return "\(hours)h"
    }
}
