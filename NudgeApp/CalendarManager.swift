//
//  CalendarManager.swift
//  NudgeApp
//
//  Created by Ammar Rosli on 06/10/2026.
//

import EventKit
import Foundation

@MainActor
@Observable
final class CalendarManager {

    private let eventStore = EKEventStore()

    var nextEvent: EKEvent?
    var authorizationStatus: EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: .event)
    }

    func requestAccess() async {
        do {
            let granted = try await eventStore.requestFullAccessToEvents()

            if granted {
                loadNextEvent()
            }
        } catch {
            print("Calendar access error: \(error)")
        }
    }

    func loadNextEvent() {
        guard authorizationStatus == .fullAccess else {
            nextEvent = nil
            return
        }

        let now = Date()

        guard let endDate = Calendar.current.date(
            byAdding: .day,
            value: 7,
            to: now
        ) else {
            return
        }

        let predicate = eventStore.predicateForEvents(
            withStart: now,
            end: endDate,
            calendars: nil
        )

        let events = eventStore.events(matching: predicate)

        nextEvent = events
            .filter { !$0.isAllDay }
            .filter { $0.endDate > now }
            .sorted { $0.startDate < $1.startDate }
            .first
    }
}
