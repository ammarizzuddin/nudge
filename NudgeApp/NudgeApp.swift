import SwiftUI

@main
struct NudgeApp: App {

    @State private var companionWindow = CompanionWindowController()
    @State private var calendarManager = CalendarManager()

    var body: some Scene {
        MenuBarExtra("Nudge", systemImage: "bell.badge") {
            NudgeMenuView(
                companionWindow: companionWindow,
                calendarManager: calendarManager
            )
        }
    }
}
