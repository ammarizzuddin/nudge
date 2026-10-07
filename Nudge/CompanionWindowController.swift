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
final class CompanionWindowController: NSObject, NSWindowDelegate {
    private var panel: NSPanel?

    override init() {
        super.init()
    }

    func show(
        event: EKEvent,
        onDismiss: @escaping () -> Void = {},
        onSnooze: @escaping (TimeInterval) -> Void = { _ in }
    ) {
        let content = CompanionView(
            event: event,
            onDismiss: onDismiss,
            onSnooze: onSnooze
        )

        if let panel {
            panel.contentView = DraggableHostingView(
                rootView: content
            )

            position(panel)
            panel.orderFrontRegardless()
        } else {
            createPanel(content: content)
        }
    }

    func hide() {
        panel?.orderOut(nil)
    }

    private func createPanel(
        content: CompanionView
    ) {
        let size = NSSize(width: 300, height: 220)

        let panel = NSPanel(
            contentRect: NSRect(
                origin: .zero,
                size: size
            ),
            styleMask: [
                .borderless,
                .nonactivatingPanel
            ],
            backing: .buffered,
            defer: false
        )

        panel.isReleasedWhenClosed = false
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.level = .floating
        panel.delegate = self

        panel.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary
        ]

        panel.contentView = DraggableHostingView(
            rootView: content
        )

        self.panel = panel

        position(panel)
        panel.orderFrontRegardless()
    }

    private func position(_ panel: NSPanel) {
        guard let screen = NSScreen.main else {
            return
        }

        let defaults = UserDefaults.standard

        if defaults.object(
            forKey: "companionPositionX"
        ) != nil,
           defaults.object(
            forKey: "companionPositionY"
           ) != nil {

            let x = defaults.double(
                forKey: "companionPositionX"
            )

            let y = defaults.double(
                forKey: "companionPositionY"
            )

            panel.setFrameOrigin(
                NSPoint(x: x, y: y)
            )

            return
        }

        let visibleFrame = screen.visibleFrame

        let x =
            visibleFrame.midX -
            (panel.frame.width / 2)

        let y =
            visibleFrame.minY + 40

        panel.setFrameOrigin(
            NSPoint(x: x, y: y)
        )
    }

    func windowDidMove(
        _ notification: Notification
    ) {
        guard let panel else {
            return
        }

        UserDefaults.standard.set(
            panel.frame.origin.x,
            forKey: "companionPositionX"
        )

        UserDefaults.standard.set(
            panel.frame.origin.y,
            forKey: "companionPositionY"
        )
    }
}
