//
//  EventLocationHelper.swift
//  Nudge
//
//  Created by Ammar Rosli on 07/10/2026.
//

import EventKit
import Foundation

enum EventLocationHelper {

    static func location(for event: EKEvent) -> String? {
        guard let location = event.location?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !location.isEmpty else {
            return nil
        }

        return location
    }

    static func mapsURL(for location: String) -> URL? {
        var components = URLComponents(
            string: "https://maps.apple.com/"
        )

        components?.queryItems = [
            URLQueryItem(
                name: "q",
                value: location
            )
        ]

        return components?.url
    }
}
