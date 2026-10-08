//
//  NudgeMenuView.swift
//  NudgeApp
//
//  Created by Ammar Rosli on 06/10/2026.
//

import AppKit
import EventKit
import SwiftUI

struct NudgeMenuView: View {

    let companionWindow: CompanionWindowController
    let calendarManager: CalendarManager
    
    @Environment(\.openSettings)
    private var openSettings

    var body: some View {
        if let event = calendarManager.nextEvent {
            Section("NEXT") {
                Text(event.title ?? "Upcoming Event")

                Text(eventSummary(for: event))

                if let meetingLink = MeetingLinkDetector.detect(in: event) {
                    Button(joinButtonTitle(for: meetingLink.provider, event: event)) {
                        NSWorkspace.shared.open(meetingLink.url)
                    }
                } else if let location = EventLocationHelper.location(for: event),
                          let mapsURL = EventLocationHelper.mapsURL(for: location) {
                    Button("Open in Maps") {
                        NSWorkspace.shared.open(mapsURL)
                    }
                }

                Button("Open Calendar") {
                    CalendarAppHelper.openCalendar()
                }
            }

            if let followingEvent = calendarManager.followingEvent {
                Section("AFTER") {
                    Text(followingEvent.title ?? "Upcoming Event")
                    Text(scheduleSummary(for: followingEvent))
                }
            }
        } else if calendarManager.authorizationStatus == .fullAccess {
            Text("No upcoming events")
            Text("Nudge is watching your selected calendars.")
        } else {
            Text("Calendar is not connected")
        }

        Divider()

        Button("Preview Nudge") {
            guard let event = calendarManager.nextEvent else {
                return
            }

            companionWindow.show(
                event: event,
                onDismiss: {
                    companionWindow.hide()
                },
                onSnooze: { _ in
                    companionWindow.hide()
                }
            )
        }
        .disabled(calendarManager.nextEvent == nil)

        Divider()

        if calendarManager.authorizationStatus == .notDetermined {
            Button("Connect Calendar…") {
                Task {
                    await calendarManager.requestAccess()
                }
            }

            Divider()
        } else if calendarManager.authorizationStatus == .restricted {
            Text("Calendar Access Restricted")

            Divider()
        } else if calendarManager.authorizationStatus != .fullAccess {
            Button("Open Calendar Privacy Settings…") {
                openCalendarPrivacySettings()
            }

            Divider()
        }

        Button("Settings…") {
            NSApp.activate(ignoringOtherApps: true)
            openSettings()
        }

        Button("About Nudge") {
            NudgeAboutPanel.show()
        }

        Divider()

        Button("Quit Nudge") {
            NSApplication.shared.terminate(nil)
        }
    }
    
    private func eventSummary(for event: EKEvent) -> String {
        let now = Date()
        let interval = event.startDate.timeIntervalSince(now)
        let startTime = event.startDate.formatted(
            date: .omitted,
            time: .shortened
        )

        if interval <= 0 {
            let elapsed = Int(abs(interval))
            let minutes = elapsed / 60

            if minutes < 1 {
                return "\(startTime) · Starting now · \(event.calendar.title)"
            }

            return "\(startTime) · Started \(minutes)m ago · \(event.calendar.title)"
        }

        let totalMinutes = Int(interval / 60)

        if totalMinutes < 1 {
            return "\(startTime) · in <1m · \(event.calendar.title)"
        }

        if totalMinutes < 60 {
            return "\(startTime) · in \(totalMinutes)m · \(event.calendar.title)"
        }

        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if minutes == 0 {
            return "\(startTime) · in \(hours)h · \(event.calendar.title)"
        }

        return "\(startTime) · in \(hours)h \(minutes)m · \(event.calendar.title)"
    }

    private func scheduleSummary(for event: EKEvent) -> String {
        let calendar = Calendar.autoupdatingCurrent
        let dateText: String

        if calendar.isDateInToday(event.startDate) {
            dateText = event.startDate.formatted(
                date: .omitted,
                time: .shortened
            )
        } else if calendar.isDateInTomorrow(event.startDate) {
            let time = event.startDate.formatted(
                date: .omitted,
                time: .shortened
            )
            dateText = "Tomorrow, \(time)"
        } else {
            dateText = event.startDate.formatted(
                .dateTime
                    .weekday(.abbreviated)
                    .hour()
                    .minute()
            )
        }

        return "\(dateText) · \(event.calendar.title)"
    }
    
    private func joinButtonTitle(
        for provider: MeetingProvider,
        event: EKEvent
    ) -> String {
        if Date() >= event.startDate {
            return "Join Now"
        }

        switch provider {
        case .googleMeet:
            return "Join Google Meet"

        case .zoom:
            return "Join Zoom"

        case .teams:
            return "Join Teams"

        case .other:
            return "Join Meeting"
        }
    }

    private func openCalendarPrivacySettings() {
        guard let url = URL(
            string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars"
        ) else {
            return
        }

        NSWorkspace.shared.open(url)
    }
}
