//
//  NudgeApp.swift
//  Nudge
//
//  Created by Ammar Rosli on 06/10/2026.
//

import SwiftUI

@main
struct NudgeApp: App {

    @State private var companionWindow: CompanionWindowController
    @State private var calendarManager: CalendarManager
    @State private var eventMonitor: EventMonitor
    @State private var menuBarClock: MenuBarClock
    @State private var onboardingWindow: OnboardingWindowController

    init() {
        NudgeDefaults.register()

        let companionWindow = CompanionWindowController()
        let calendarManager = CalendarManager()

        let eventMonitor = EventMonitor(
            calendarManager: calendarManager,
            companionWindow: companionWindow
        )

        let menuBarClock = MenuBarClock()
        let onboardingWindow = OnboardingWindowController()

        _companionWindow = State(initialValue: companionWindow)
        _calendarManager = State(initialValue: calendarManager)
        _eventMonitor = State(initialValue: eventMonitor)
        _menuBarClock = State(initialValue: menuBarClock)
        _onboardingWindow = State(initialValue: onboardingWindow)

        eventMonitor.start()
        menuBarClock.start()

        Task { @MainActor in
            onboardingWindow.showIfNeeded(
                calendarManager: calendarManager
            )
        }
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
