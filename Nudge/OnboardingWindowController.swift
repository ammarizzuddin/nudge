import AppKit
import SwiftUI

@MainActor
final class OnboardingWindowController {
    private var window: NSWindow?

    func showIfNeeded(calendarManager: CalendarManager) {
        guard !UserDefaults.standard.bool(
            forKey: "hasCompletedOnboarding"
        ) else {
            return
        }

        let content = OnboardingView(
            calendarManager: calendarManager,
            onFinish: { [weak self] in
                UserDefaults.standard.set(
                    true,
                    forKey: "hasCompletedOnboarding"
                )
                self?.window?.close()
                self?.window = nil
            }
        )

        let window = NSWindow(
            contentRect: NSRect(
                origin: .zero,
                size: NSSize(width: 520, height: 540)
            ),
            styleMask: [
                .titled,
                .closable
            ],
            backing: .buffered,
            defer: false
        )

        window.title = "Welcome to Nudge"
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: content)
        window.center()

        self.window = window

        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }
}
