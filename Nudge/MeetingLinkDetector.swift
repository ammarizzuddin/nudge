//
//  MeetingProvider.swift
//  NudgeApp
//
//  Created by Ammar Rosli on 06/10/2026.
//

import EventKit
import Foundation

enum MeetingProvider {
    case zoom
    case teams
    case googleMeet
    case other
}

struct MeetingLink {
    let url: URL
    let provider: MeetingProvider
}

enum MeetingLinkDetector {

    static func detect(in event: EKEvent) -> MeetingLink? {
        var candidates: [URL] = []

        // Calendar's structured URL field
        if let url = event.url {
            candidates.append(url)
        }

        // Links embedded in notes
        if let notes = event.notes {
            candidates.append(contentsOf: extractURLs(from: notes))
        }

        // Links embedded in location
        if let location = event.location {
            candidates.append(contentsOf: extractURLs(from: location))
        }

        // Prefer recognised meeting providers.
        for url in candidates {
            if let provider = provider(for: url) {
                return MeetingLink(
                    url: url,
                    provider: provider
                )
            }
        }

        return nil
    }

    private static func extractURLs(from text: String) -> [URL] {
        guard let detector = try? NSDataDetector(
            types: NSTextCheckingResult.CheckingType.link.rawValue
        ) else {
            return []
        }

        let range = NSRange(
            text.startIndex..<text.endIndex,
            in: text
        )

        return detector.matches(
            in: text,
            options: [],
            range: range
        )
        .compactMap(\.url)
    }

    private static func provider(for url: URL) -> MeetingProvider? {
        guard let host = url.host?.lowercased() else {
            return nil
        }

        if host == "zoom.us" || host.hasSuffix(".zoom.us") {
            return .zoom
        }

        if host == "teams.microsoft.com" ||
            host.hasSuffix(".teams.microsoft.com") ||
            host == "teams.live.com" {
            return .teams
        }

        if host == "meet.google.com" {
            return .googleMeet
        }

        return nil
    }
}
