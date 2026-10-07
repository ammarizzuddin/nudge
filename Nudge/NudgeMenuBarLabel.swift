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
                    ReminderTiming.countdownText(
                        startDate: event.startDate,
                        now: date
                    )
                )
                .monospacedDigit()
            }
        }
    }

    private func shouldShowCountdown(
        for event: EKEvent,
        at date: Date
    ) -> Bool {
        let gracePeriod = UserDefaults.standard.double(
            forKey: "eventGracePeriod"
        )

        return ReminderTiming.isActive(
            startDate: event.startDate,
            now: date,
            reminderLeadTime: reminderLeadTime * 60,
            gracePeriod: gracePeriod * 60
        )
    }
}
