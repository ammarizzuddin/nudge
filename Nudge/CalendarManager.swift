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
    var onEventStoreChanged: (() -> Void)?

    var authorizationStatus: EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: .event)
    }

    var availableCalendars: [EKCalendar] {
        guard authorizationStatus == .fullAccess else {
            return []
        }

        return eventStore
            .calendars(for: .event)
            .sorted {
                $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
    }
    
    var calendarsBySource: [(source: EKSource, calendars: [EKCalendar])] {
        let grouped = Dictionary(
            grouping: availableCalendars,
            by: { $0.source.sourceIdentifier }
        )

        return grouped.compactMap { _, calendars in
            guard let source = calendars.first?.source else {
                return nil
            }

            return (
                source: source,
                calendars: calendars.sorted {
                    $0.title.localizedCaseInsensitiveCompare($1.title)
                        == .orderedAscending
                }
            )
        }
        .sorted {
            $0.source.title.localizedCaseInsensitiveCompare(
                $1.source.title
            ) == .orderedAscending
        }
    }
    
    init() {
        NotificationCenter.default.addObserver(
            forName: .EKEventStoreChanged,
            object: eventStore,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.onEventStoreChanged?()
            }
        }
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

        let eventGracePeriod = UserDefaults.standard.double(
            forKey: "eventGracePeriod"
        )

        let graceInterval = eventGracePeriod * 60
        let startDate = now.addingTimeInterval(-graceInterval)

        let excludedCalendarIdentifiers =
            excludedCalendarIdentifiers()

        let enabledCalendars = eventStore
            .calendars(for: .event)
            .filter {
                !excludedCalendarIdentifiers.contains(
                    $0.calendarIdentifier
                )
            }

        guard !enabledCalendars.isEmpty else {
            nextEvent = nil
            return
        }

        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: enabledCalendars
        )

        let events = eventStore.events(matching: predicate)

        let relevantEvents = events
            .filter { !$0.isAllDay }
            .filter {
                $0.startDate >= startDate
            }
            .sorted {
                $0.startDate < $1.startDate
            }

        let startedEvents = relevantEvents.filter {
            $0.startDate <= now
        }

        let upcomingEvents = relevantEvents.filter {
            $0.startDate > now
        }

        if let mostRecentlyStarted = startedEvents.last {
            nextEvent = mostRecentlyStarted
        } else {
            nextEvent = upcomingEvents.first
        }
    }
    
    private func excludedCalendarIdentifiers() -> Set<String> {
        let data = UserDefaults.standard.data(
            forKey: "excludedCalendarIdentifiers"
        )

        guard let data,
              let identifiers = try? JSONDecoder().decode(
                  Set<String>.self,
                  from: data
              ) else {
            return []
        }

        return identifiers
    }
}
