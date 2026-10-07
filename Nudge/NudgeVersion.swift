//
//  NudgeVersion.swift
//  Nudge
//
//  Created by Ammar Rosli on 07/10/2026.
//

import Foundation

enum NudgeVersion {
    static var displayVersion: String {
        let version = Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String ?? "Unknown"

        let build = Bundle.main.object(
            forInfoDictionaryKey: "CFBundleVersion"
        ) as? String

        guard let build, !build.isEmpty else {
            return version
        }

        return "\(version) (\(build))"
    }
}
