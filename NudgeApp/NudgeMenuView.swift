//
//  NudgeMenuView.swift
//  NudgeApp
//
//  Created by Ammar Rosli on 06/10/2026.
//

import EventKit
import SwiftUI

struct NudgeMenuView: View {

    let companionWindow: CompanionWindowController
    let calendarManager: CalendarManager

    var body: some View {
        if let event = calendarManager.nextEvent {
            Text("Up Next")
                .font(.caption)

            Text(event.title ?? "Upcoming Event")

            Text(event.startDate, style: .relative)

            Divider()
        }

        Button("Show Nudge") {
            companionWindow.show(
                event: calendarManager.nextEvent
            )
        }

        Button("Hide Nudge") {
            companionWindow.hide()
        }

        Divider()

        Button("Connect Calendar") {
            Task {
                await calendarManager.requestAccess()
            }
        }

        Divider()

        SettingsLink {
            Text("Settings…")
        }

        Divider()

        Button("Quit Nudge") {
            NSApplication.shared.terminate(nil)
        }
    }
}
