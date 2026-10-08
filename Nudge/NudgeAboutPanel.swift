//
//  NudgeAboutPanel.swift
//  Nudge
//
//  Created by Ammar Rosli on 08/10/2026.
//

import AppKit

@MainActor
enum NudgeAboutPanel {
    private static let tagline = "A gentle reminder, right when you need it."

    static func show() {
        let application = NSApplication.shared

        application.activate(ignoringOtherApps: true)
        application.orderFrontStandardAboutPanel(options: [
            .applicationName: "Nudge",
            .applicationIcon: applicationIcon,
            .applicationVersion: shortVersion,
            .version: buildVersion,
            .credits: credits
        ])
    }

    private static var applicationIcon: NSImage {
        let iconName = Bundle.main.object(
            forInfoDictionaryKey: "CFBundleIconFile"
        ) as? String

        if let iconName {
            let resourceName = (iconName as NSString).deletingPathExtension
            let pathExtension = (iconName as NSString).pathExtension
            let fileExtension = pathExtension.isEmpty ? "icns" : pathExtension

            if let iconURL = Bundle.main.url(
                forResource: resourceName,
                withExtension: fileExtension
            ), let icon = NSImage(contentsOf: iconURL) {
                return icon
            }
        }

        return NSApplication.shared.applicationIconImage
    }

    private static var credits: NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        return NSAttributedString(
            string: "\(tagline)\n\nCreated by Ammar Rosli.\nReleased under the MIT License.",
            attributes: [.paragraphStyle: paragraphStyle]
        )
    }

    private static var shortVersion: String {
        Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String ?? "Unknown"
    }

    private static var buildVersion: String {
        Bundle.main.object(
            forInfoDictionaryKey: "CFBundleVersion"
        ) as? String ?? "Unknown"
    }
}
