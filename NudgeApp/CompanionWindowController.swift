//
//  CompanionWindowController.swift
//  NudgeApp
//
//  Created by Ammar Rosli on 06/10/2026.
//

import AppKit
import EventKit
import SwiftUI

@MainActor
final class CompanionWindowController {

    private var panel: NSPanel?

    func show(event: EKEvent? = nil) {
        createPanel(event: event)

        guard let panel else { return }

        position(panel)
        panel.orderFrontRegardless()
    }

    func hide() {
        panel?.orderOut(nil)
    }

    private func createPanel(event: EKEvent?) {
        let size = NSSize(width: 300, height: 220)

        let panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [
                .borderless,
                .nonactivatingPanel
            ],
            backing: .buffered,
            defer: false
        )

        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false

        panel.level = .floating

        panel.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary
        ]

        panel.isMovableByWindowBackground = true

        panel.contentView = NSHostingView(
            rootView: CompanionView(event: event)
        )

        self.panel = panel
    }

    private func position(_ panel: NSPanel) {
        guard let screen = NSScreen.main else { return }

        let visibleFrame = screen.visibleFrame

        let x = visibleFrame.maxX - panel.frame.width - 30
        let y = visibleFrame.minY + 30

        panel.setFrameOrigin(
            NSPoint(x: x, y: y)
        )
    }
}
