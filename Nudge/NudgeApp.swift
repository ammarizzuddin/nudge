import SwiftUI

@main
struct NudgeApp: App {

    @State private var companionWindow: CompanionWindowController
    @State private var calendarManager: CalendarManager
    @State private var eventMonitor: EventMonitor
    @State private var menuBarClock: MenuBarClock

    init() {
        let companionWindow = CompanionWindowController()
        let calendarManager = CalendarManager()

        let eventMonitor = EventMonitor(
            calendarManager: calendarManager,
            companionWindow: companionWindow
        )

        let menuBarClock = MenuBarClock()

        _companionWindow = State(initialValue: companionWindow)
        _calendarManager = State(initialValue: calendarManager)
        _eventMonitor = State(initialValue: eventMonitor)
        _menuBarClock = State(initialValue: menuBarClock)

        eventMonitor.start()
        menuBarClock.start()
    }

    var body: some Scene {
        MenuBarExtra {
            NudgeMenuView(
                companionWindow: companionWindow,
                calendarManager: calendarManager
            )
        } label: {
            NudgeMenuBarLabel(
                calendarManager: calendarManager,
                date: menuBarClock.now
            )
        }
        
        Settings {
            NudgeSettingsView(
                calendarManager: calendarManager,
                eventMonitor: eventMonitor
            )
        }
    }
}
