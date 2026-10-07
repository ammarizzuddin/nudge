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
            Text("UP NEXT")
                .font(.caption)

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

            Divider()
        }

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

        if calendarManager.authorizationStatus != .fullAccess {
            Button("Connect Calendar…") {
                Task {
                    await calendarManager.requestAccess()
                }
            }

            Divider()
        }

        Button("Settings…") {
            NSApp.activate(ignoringOtherApps: true)
            openSettings()
        }

        Divider()

        Button("Quit Nudge") {
            NSApplication.shared.terminate(nil)
        }
    }
    
    private func eventSummary(for event: EKEvent) -> String {
        let now = Date()
        let interval = event.startDate.timeIntervalSince(now)

        if interval <= 0 {
            let elapsed = Int(abs(interval))
            let minutes = elapsed / 60

            if minutes < 1 {
                return "Starting now · \(event.calendar.title)"
            }

            return "Started \(minutes)m ago · \(event.calendar.title)"
        }

        let totalMinutes = Int(interval / 60)

        if totalMinutes < 1 {
            return "Starts in <1m · \(event.calendar.title)"
        }

        if totalMinutes < 60 {
            return "Starts in \(totalMinutes)m · \(event.calendar.title)"
        }

        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if minutes == 0 {
            return "Starts in \(hours)h · \(event.calendar.title)"
        }

        return "Starts in \(hours)h \(minutes)m · \(event.calendar.title)"
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
}
