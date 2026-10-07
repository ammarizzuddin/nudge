//
//  EventMonitor.swift
//  NudgeApp
//
//  Created by Ammar Rosli on 06/10/2026.
//

import Foundation
import EventKit

@MainActor
final class EventMonitor {

    private let calendarManager: CalendarManager
    private let companionWindow: CompanionWindowController

    private var timer: Timer?
    private var eventStartTimer: Timer?
    private var snoozeTimer: Timer?
    private var gracePeriodTimer: Timer?

    // Event currently being shown by Nudge.
    private var visibleEventIdentifier: String?
    private var visibleEventStartDate: Date?

    // Event explicitly dismissed by the user.
    private var dismissedEventIdentifier: String?

    // Snooze state.
    private var snoozedEventIdentifier: String?
    private var snoozedUntil: Date?
    
    private var alertSoundEventIdentifier: String?
    private var alertSoundTimer: Timer?

    init(
        calendarManager: CalendarManager,
        companionWindow: CompanionWindowController
    ) {
        self.calendarManager = calendarManager
        self.companionWindow = companionWindow
        
        calendarManager.onEventStoreChanged = { [weak self] in
            self?.checkNow()
        }
    }

    func start() {
        checkForUpcomingEvent()

        timer = Timer.scheduledTimer(
            withTimeInterval: 30,
            repeats: true
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.checkForUpcomingEvent()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil

        eventStartTimer?.invalidate()
        eventStartTimer = nil

        snoozeTimer?.invalidate()
        snoozeTimer = nil
    }
    
    func checkNow() {
        checkForUpcomingEvent()
    }

    private func checkForUpcomingEvent() {
        calendarManager.loadNextEvent()
        
        // temporary
        if let event = calendarManager.nextEvent {
            print(
                "Nudge monitor:",
                event.title ?? "Untitled",
                "| Calendar:",
                event.calendar.title
            )
        } else {
            print("Nudge monitor: No eligible event")
        }

        guard let event = calendarManager.nextEvent else {
            print("Nudge monitor: hiding companion")
            hideCompanion()
            return
        }

        let eventIdentifier = event.eventIdentifier
        let now = Date()
        let timeUntilEvent = event.startDate.timeIntervalSince(now)

        let reminderLeadTime = UserDefaults.standard.double(
            forKey: "reminderLeadTime"
        )

        let reminderMinutes = reminderLeadTime > 0
            ? reminderLeadTime
            : 5

        let reminderInterval: TimeInterval =
            reminderMinutes * 60

        let eventGracePeriod = UserDefaults.standard.double(
            forKey: "eventGracePeriod"
        )

        let graceInterval: TimeInterval =
            eventGracePeriod * 60

        let timeSinceEventStarted =
            now.timeIntervalSince(event.startDate)

        let isUpcoming =
            timeUntilEvent > 0 &&
            timeUntilEvent <= reminderInterval

        let isWithinGracePeriod =
            timeSinceEventStarted >= 0 &&
            timeSinceEventStarted <= graceInterval

        guard isUpcoming || isWithinGracePeriod else {
            if visibleEventIdentifier != nil {
                hideCompanion()
            }
            return
        }

        // The user dismissed this event.
        guard dismissedEventIdentifier != eventIdentifier else {
            return
        }

        // The event is snoozed.
        if snoozedEventIdentifier == eventIdentifier,
           let snoozedUntil {

            if now < snoozedUntil {
                return
            }

            // Snooze has expired.
            self.snoozedEventIdentifier = nil
            self.snoozedUntil = nil
        }

        // The same unchanged event is already on screen.
        if visibleEventIdentifier == eventIdentifier,
           visibleEventStartDate == event.startDate {
            return
        }

        showCompanion(for: event)
    }

    private func showCompanion(for event: EKEvent) {
        let wasAlreadyVisible =
            visibleEventIdentifier != nil
        
        visibleEventIdentifier = event.eventIdentifier
        visibleEventStartDate = event.startDate

        companionWindow.show(
            event: event,
            onDismiss: { [weak self] in
                guard let self else { return }
                self.dismiss(event: event)
            },
            onSnooze: { [weak self] duration in
                guard let self else { return }
                self.snooze(
                    event: event,
                    duration: duration
                )
            }
        )
        
        if !wasAlreadyVisible {
            NudgeSoundPlayer.playSelectedSound()
        }

        scheduleEventStart(at: event.startDate)
        scheduleGracePeriodEnd(for: event)
        scheduleAlertSound(for: event)
    }

    private func dismiss(event: EKEvent) {
        dismissedEventIdentifier = event.eventIdentifier

        eventStartTimer?.invalidate()
        eventStartTimer = nil

        snoozeTimer?.invalidate()
        snoozeTimer = nil

        visibleEventIdentifier = nil
        visibleEventStartDate = nil

        companionWindow.hide()
    }

    private func snooze(
        event: EKEvent,
        duration: TimeInterval
    ) {
        let wakeDate = Date().addingTimeInterval(duration)

        snoozedEventIdentifier = event.eventIdentifier
        snoozedUntil = wakeDate

        eventStartTimer?.invalidate()
        eventStartTimer = nil

        visibleEventIdentifier = nil
        visibleEventStartDate = nil

        companionWindow.hide()

        // Cancel any previous snooze timer.
        snoozeTimer?.invalidate()

        snoozeTimer = Timer.scheduledTimer(
            withTimeInterval: duration,
            repeats: false
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.wakeFromSnooze()
            }
        }
    }
    
    private func wakeFromSnooze() {
        snoozeTimer = nil

        guard let snoozedEventIdentifier else {
            return
        }

        // Refresh the calendar rather than relying on the old EKEvent object.
        calendarManager.loadNextEvent()

        guard let event = calendarManager.nextEvent,
              event.eventIdentifier == snoozedEventIdentifier else {
            self.snoozedEventIdentifier = nil
            self.snoozedUntil = nil
            return
        }

        self.snoozedEventIdentifier = nil
        self.snoozedUntil = nil

        // Don't bring Nudge back if the meeting has already started.
        guard event.startDate > Date() else {
            return
        }

        showCompanion(for: event)
    }

    private func hideCompanion() {
        eventStartTimer?.invalidate()
        eventStartTimer = nil

        gracePeriodTimer?.invalidate()
        gracePeriodTimer = nil

        snoozeTimer?.invalidate()
        snoozeTimer = nil

        alertSoundTimer?.invalidate()
        alertSoundTimer = nil

        visibleEventIdentifier = nil
        visibleEventStartDate = nil

        companionWindow.hide()
    }

    private func scheduleEventStart(at date: Date) {
        eventStartTimer?.invalidate()

        let interval = date.timeIntervalSinceNow

        guard interval > 0 else {
            return
        }

        eventStartTimer = Timer.scheduledTimer(
            withTimeInterval: interval,
            repeats: false
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.checkForUpcomingEvent()
            }
        }
    }
    
    private func currentEventDidStart() {
        hideCompanion()
        checkForUpcomingEvent()
    }
    
    private func scheduleAlertSound(for event: EKEvent) {
        alertSoundTimer?.invalidate()
        alertSoundTimer = nil

        guard let eventIdentifier = event.eventIdentifier else {
            return
        }

        let alertDate = event.startDate.addingTimeInterval(-30)
        let interval = alertDate.timeIntervalSinceNow

        guard alertSoundEventIdentifier != eventIdentifier else {
            return
        }

        if interval <= 0 {
            playAlertSound(for: eventIdentifier)
            return
        }

        alertSoundTimer = Timer.scheduledTimer(
            withTimeInterval: interval,
            repeats: false
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.playAlertSound(
                    for: eventIdentifier
                )
            }
        }
    }
    
    private func playAlertSound(
        for eventIdentifier: String
    ) {
        guard visibleEventIdentifier == eventIdentifier else {
            return
        }

        guard alertSoundEventIdentifier != eventIdentifier else {
            return
        }

        alertSoundEventIdentifier = eventIdentifier

        NudgeSoundPlayer.playSelectedSound()
    }
    
    private func scheduleGracePeriodEnd(for event: EKEvent) {
        gracePeriodTimer?.invalidate()
        gracePeriodTimer = nil

        let gracePeriod = UserDefaults.standard.double(
            forKey: "eventGracePeriod"
        )

        guard gracePeriod > 0 else {
            return
        }

        let graceEndDate = event.startDate.addingTimeInterval(
            gracePeriod * 60
        )

        let interval = graceEndDate.timeIntervalSinceNow

        guard interval > 0 else {
            return
        }

        gracePeriodTimer = Timer.scheduledTimer(
            withTimeInterval: interval,
            repeats: false
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.checkForUpcomingEvent()
            }
        }
    }
}
