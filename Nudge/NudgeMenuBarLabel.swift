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
    let date: Date

    @AppStorage("showCountdownInMenuBar")
    private var showCountdownInMenuBar = NudgeDefaults.showCountdownInMenuBar
    
    @AppStorage("reminderLeadTime")
    private var reminderLeadTime = NudgeDefaults.reminderLeadTime

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "bell.badge")

            if showCountdownInMenuBar,
               let event = calendarManager.nextEvent,
               shouldShowCountdown(for: event, at: date) {
                Text(
                    countdownText(
                        for: event,
                        at: date
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
    
    private func shouldShowCountdown(
        for event: EKEvent,
        at date: Date
    ) -> Bool {
        let timeUntilEvent = event.startDate.timeIntervalSince(date)
        let reminderInterval = reminderLeadTime * 60

        if timeUntilEvent > 0 {
            return timeUntilEvent <= reminderInterval
        }

        let gracePeriod = UserDefaults.standard.double(
            forKey: "eventGracePeriod"
        )

        guard gracePeriod > 0 else {
            return false
        }

        let timeSinceStart = abs(timeUntilEvent)

        return timeSinceStart <= gracePeriod * 60
    }
}
