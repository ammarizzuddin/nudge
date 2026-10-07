//
//  CalendarAppHelper.swift
//  Nudge
//
//  Created by Ammar Rosli on 07/10/2026.
//

import AppKit

enum CalendarAppHelper {

    static func openCalendar() {
        guard let url = NSWorkspace.shared.urlForApplication(
            withBundleIdentifier: "com.apple.iCal"
        ) else {
            return
        }

        NSWorkspace.shared.openApplication(
            at: url,
            configuration: NSWorkspace.OpenConfiguration()
        )
    }
}
