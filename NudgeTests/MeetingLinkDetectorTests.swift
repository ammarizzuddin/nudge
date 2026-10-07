//
//  MeetingLinkDetectorTests.swift
//  Nudge
//
//  Created by Ammar Rosli on 07/10/2026.
//

import EventKit
import XCTest
@testable import Nudge

final class MeetingLinkDetectorTests: XCTestCase {
    private let eventStore = EKEventStore()

    func testDetectsZoomFromStructuredURL() {
        let meeting = detect(url: "https://company.zoom.us/j/123456")

        XCTAssertEqual(meeting?.provider, .zoom)
        XCTAssertEqual(meeting?.url.host, "company.zoom.us")
    }

    func testDetectsTeamsFromNotes() {
        let event = EKEvent(eventStore: eventStore)
        event.notes = "Join at https://teams.microsoft.com/l/meetup-join/example"

        let meeting = MeetingLinkDetector.detect(in: event)

        XCTAssertEqual(meeting?.provider, .teams)
    }

    func testDetectsGoogleMeetFromLocation() {
        let event = EKEvent(eventStore: eventStore)
        event.location = "Video call: https://meet.google.com/abc-defg-hij"

        let meeting = MeetingLinkDetector.detect(in: event)

        XCTAssertEqual(meeting?.provider, .googleMeet)
    }

    func testIgnoresUnsupportedWebLink() {
        XCTAssertNil(detect(url: "https://example.com/meeting"))
    }

    private func detect(url: String) -> MeetingLink? {
        let event = EKEvent(eventStore: eventStore)
        event.url = URL(string: url)
        return MeetingLinkDetector.detect(in: event)
    }
}
