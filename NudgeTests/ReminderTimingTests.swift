//
//  ReminderTimingTests.swift
//  Nudge
//
//  Created by Ammar Rosli on 07/10/2026.
//

import XCTest
@testable import Nudge

final class ReminderTimingTests: XCTestCase {
    private let now = Date(timeIntervalSinceReferenceDate: 1_000_000)

    func testEventOutsideReminderWindowIsInactive() {
        XCTAssertFalse(
            isActive(startOffset: 301, leadTime: 300, gracePeriod: 300)
        )
    }

    func testEventAtReminderBoundaryIsActive() {
        XCTAssertTrue(
            isActive(startOffset: 300, leadTime: 300, gracePeriod: 300)
        )
    }

    func testStartedEventRemainsActiveThroughGraceBoundary() {
        XCTAssertTrue(
            isActive(startOffset: -300, leadTime: 300, gracePeriod: 300)
        )
    }

    func testEventAtStartIsActiveWhenGracePeriodIsEnabled() {
        XCTAssertTrue(
            isActive(startOffset: 0, leadTime: 300, gracePeriod: 300)
        )
    }

    func testEventAfterGracePeriodIsInactive() {
        XCTAssertFalse(
            isActive(startOffset: -301, leadTime: 300, gracePeriod: 300)
        )
    }

    func testZeroGracePeriodStopsReminderAtEventStart() {
        XCTAssertFalse(
            isActive(startOffset: 0, leadTime: 300, gracePeriod: 0)
        )
    }

    func testCountdownLabels() {
        XCTAssertEqual(countdownText(startOffset: -1), "Now")
        XCTAssertEqual(countdownText(startOffset: 0), "Now")
        XCTAssertEqual(countdownText(startOffset: 59), "<1m")
        XCTAssertEqual(countdownText(startOffset: 60), "1m")
        XCTAssertEqual(countdownText(startOffset: 3599), "59m")
        XCTAssertEqual(countdownText(startOffset: 3600), "1h")
        XCTAssertEqual(countdownText(startOffset: 7199), "1h")
    }

    func testStartedEventIsSelectedWhenNextEventIsNotImminent() {
        let selected = selectedOffset(
            from: [-120, 600],
            leadTime: 300
        )

        XCTAssertEqual(selected, -120)
    }

    func testImminentEventTakesPriorityOverStartedEvent() {
        let selected = selectedOffset(
            from: [-120, 240],
            leadTime: 300
        )

        XCTAssertEqual(selected, 240)
    }

    func testEarliestUpcomingEventIsSelectedFromUnsortedInput() {
        let selected = selectedOffset(
            from: [240, 120, 180],
            leadTime: 300
        )

        XCTAssertEqual(selected, 120)
    }

    func testNextUpcomingEventIsSelectedWithoutCurrentEvent() {
        let selected = selectedOffset(
            from: [900, 600],
            leadTime: 300
        )

        XCTAssertEqual(selected, 600)
    }

    func testNoEventIsSelectedFromEmptyInput() {
        XCTAssertNil(
            ReminderTiming.selectedEvent(
                from: [Date](),
                now: now,
                reminderLeadTime: 300,
                startDate: { $0 }
            )
        )
    }

    func testFollowingEventUsesChronologicalOrder() {
        let dates = [600.0, 120.0, 300.0].map(
            now.addingTimeInterval
        )
        let selected = dates[1]

        let following = ReminderTiming.followingEvent(
            after: selected,
            from: dates,
            startDate: { $0 },
            isSameEvent: { $0 == $1 }
        )

        XCTAssertEqual(
            following?.timeIntervalSince(now),
            300
        )
    }

    func testFollowingEventCanShareSelectedStartTime() {
        struct Event: Equatable {
            let id: Int
            let startDate: Date
        }

        let selected = Event(id: 1, startDate: now)
        let simultaneous = Event(id: 2, startDate: now)

        let following = ReminderTiming.followingEvent(
            after: selected,
            from: [selected, simultaneous],
            startDate: \.startDate,
            isSameEvent: { $0.id == $1.id }
        )

        XCTAssertEqual(following, simultaneous)
    }

    private func isActive(
        startOffset: TimeInterval,
        leadTime: TimeInterval,
        gracePeriod: TimeInterval
    ) -> Bool {
        ReminderTiming.isActive(
            startDate: now.addingTimeInterval(startOffset),
            now: now,
            reminderLeadTime: leadTime,
            gracePeriod: gracePeriod
        )
    }

    private func countdownText(
        startOffset: TimeInterval
    ) -> String {
        ReminderTiming.countdownText(
            startDate: now.addingTimeInterval(startOffset),
            now: now
        )
    }

    private func selectedOffset(
        from offsets: [TimeInterval],
        leadTime: TimeInterval
    ) -> TimeInterval? {
        let dates = offsets.map(now.addingTimeInterval)

        guard let selected = ReminderTiming.selectedEvent(
            from: dates,
            now: now,
            reminderLeadTime: leadTime,
            startDate: { $0 }
        ) else {
            return nil
        }

        return selected.timeIntervalSince(now)
    }
}
