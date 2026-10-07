//
//  ReminderTiming.swift
//  Nudge
//
//  Created by Ammar Rosli on 07/10/2026.
//

import Foundation

enum ReminderTiming {
    static func isActive(
        startDate: Date,
        now: Date,
        reminderLeadTime: TimeInterval,
        gracePeriod: TimeInterval
    ) -> Bool {
        let timeUntilStart = startDate.timeIntervalSince(now)

        if timeUntilStart > 0 {
            return timeUntilStart <= reminderLeadTime
        }

        guard gracePeriod > 0 else {
            return false
        }

        return abs(timeUntilStart) <= gracePeriod
    }

    static func countdownText(
        startDate: Date,
        now: Date
    ) -> String {
        let remaining = startDate.timeIntervalSince(now)

        if remaining <= 0 {
            return "Now"
        }

        let minutes = Int(remaining) / 60

        if minutes < 1 {
            return "<1m"
        }

        if minutes < 60 {
            return "\(minutes)m"
        }

        return "\(minutes / 60)h"
    }

    static func selectedEvent<Event>(
        from events: [Event],
        now: Date,
        reminderLeadTime: TimeInterval,
        startDate: (Event) -> Date
    ) -> Event? {
        let sortedEvents = events.sorted {
            startDate($0) < startDate($1)
        }

        let startedEvents = sortedEvents.filter {
            startDate($0) <= now
        }
        let upcomingEvents = sortedEvents.filter {
            startDate($0) > now
        }
        let reminderEndDate = now.addingTimeInterval(
            reminderLeadTime
        )

        if let imminentEvent = upcomingEvents.first(
            where: { startDate($0) <= reminderEndDate }
        ) {
            return imminentEvent
        }

        return startedEvents.last ?? upcomingEvents.first
    }
}
