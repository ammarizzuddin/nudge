//
//  CompanionView.swift
//  NudgeApp
//
//  Created by Ammar Rosli on 06/10/2026.
//

import AppKit
import EventKit
import SwiftUI

struct CompanionView: View {
    let event: EKEvent
    let onDismiss: () -> Void
    let onSnooze: (TimeInterval) -> Void
    
    @AppStorage("mascotAnimationMode")
    private var mascotAnimationMode: MascotAnimationMode = .full
    
    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion
    
    @State private var isPresented = false
    
    private var meetingLink: MeetingLink? {
        MeetingLinkDetector.detect(in: event)
    }
    
    private var eventLocation: String? {
        EventLocationHelper.location(for: event)
    }

    var body: some View {
        TimelineView(.animation) { context in
            VStack(spacing: -4) {

                // Nudge mascot
                ZStack {
                    Image(mascotImage(at: context.date))
                        .resizable()
                        .scaledToFit()
                        .id(mascotImage(at: context.date))
                        .transition(
                            .asymmetric(
                                insertion: .opacity.combined(with: .scale(scale: 0.96)),
                                removal: .opacity
                            )
                        )
                }
                .frame(width: 110, height: 110)
                .offset(
                    x: horizontalOffset(at: context.date),
                    y: verticalOffset(at: context.date)
                )
                .rotationEffect(
                    .degrees(rotation(at: context.date))
                )
                .shadow(
                    color: .black.opacity(0.18),
                    radius: 6,
                    y: 4
                )
                .animation(
                    .easeInOut(duration: 0.25),
                    value: mascotImage(at: context.date)
                )
                .zIndex(1)

                // Event card
                VStack(spacing: 7) {
                    Button {
                        CalendarAppHelper.openCalendar()
                    } label: {
                        HStack(spacing: 5) {
                            Text(event.title ?? "Upcoming Event")
                                .lineLimit(1)

                            Image(systemName: "arrow.up.forward.app")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(.tertiary)
                        }
                        .font(.system(size: 14, weight: .semibold))
                    }
                    .buttonStyle(.plain)
                    .help("Open Calendar")

                    HStack(spacing: 5) {
                        Text(countdownText(at: context.date))
                            .monospacedDigit()

                        Text("·")
                            .foregroundStyle(.tertiary)

                        Text(event.calendar.title)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                    
                    if meetingLink == nil,
                       let eventLocation {

                        Label(
                            eventLocation,
                            systemImage: "mappin.and.ellipse"
                        )
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    }

                    if let meetingLink {
                        Button {
                            NSWorkspace.shared.open(meetingLink.url)
                            onDismiss()
                        } label: {
                            Label(
                                joinButtonTitle(
                                    for: meetingLink.provider,
                                    at: context.date
                                ),
                                systemImage: "video.fill"
                            )
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.black.opacity(0.85))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 7)
                            .padding(.horizontal, 12)
                            .background(Color("NudgeAccent"))
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 7,
                                    style: .continuous
                                )
                            )
                        }
                        .buttonStyle(.plain)
                    } else if let eventLocation,
                              let mapsURL = EventLocationHelper.mapsURL(
                                  for: eventLocation
                              ) {
                        
                        Button {
                            NSWorkspace.shared.open(mapsURL)
                            onDismiss()
                        } label: {
                            Label(
                                "Open in Maps",
                                systemImage: "map.fill"
                            )
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.black.opacity(0.85))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 7)
                            .padding(.horizontal, 12)
                            .background(Color("NudgeAccent"))
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 7,
                                    style: .continuous
                                )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    
                    let remaining = event.startDate.timeIntervalSince(context.date)

                    HStack(spacing: 16) {
                        if remaining > 30 {
                            Menu {
                                if remaining > 60 {
                                    Button("1 minute") {
                                        onSnooze(60)
                                    }
                                }

                                if remaining > 120 {
                                    Button("2 minutes") {
                                        onSnooze(120)
                                    }
                                }

                                Button("Until 30 seconds before") {
                                    onSnooze(max(remaining - 30, 0))
                                }
                            } label: {
                                Label("Snooze", systemImage: "clock")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(.secondary)
                            }
                            .menuStyle(.borderlessButton)
                            .fixedSize()
                        }

                        Button {
                            onDismiss()
                        } label: {
                            Label("Dismiss", systemImage: "xmark")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                        .fixedSize()
                    }
                    .fixedSize(horizontal: true, vertical: false)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 11)
                .background(.regularMaterial)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 14,
                        style: .continuous
                    )
                )
                .overlay {
                    RoundedRectangle(
                        cornerRadius: 14,
                        style: .continuous
                    )
                    .stroke(.white.opacity(0.15))
                }
                .shadow(
                    color: .black.opacity(0.2),
                    radius: 14,
                    y: 6
                )
            }
        }
        .padding(24)
        .scaleEffect(isPresented ? 1 : 0.8)
        .opacity(isPresented ? 1 : 0)
        .offset(y: isPresented ? 0 : 12)
        .onAppear {
            withAnimation(
                .spring(response: 0.45, dampingFraction: 0.72)
            ) {
                isPresented = true
            }
        }
    }

    private func mascotImage(at date: Date) -> String {
        let remaining = event.startDate.timeIntervalSince(date)

        switch remaining {
        case ...30:
            return "nudge-alert"

        case ...120:
            return "nudge-wave"

        default:
            return "nudge-idle"
        }
    }
    
    private func verticalOffset(at date: Date) -> CGFloat {
        let remaining = event.startDate.timeIntervalSince(date)
        let time = date.timeIntervalSinceReferenceDate

        let fullOffset: CGFloat

        if remaining <= 30 {
            // Alert: quicker bounce
            fullOffset = CGFloat(sin(time * 6.0)) * 4
        } else {
            // Idle + wave: slow floating
            fullOffset = CGFloat(sin(time * 2.2)) * 5
        }

        switch effectiveAnimationMode {
        case .full:
            return fullOffset

        case .reduced:
            return fullOffset * 0.35

        case .still:
            return 0
        }
    }

    private func horizontalOffset(at date: Date) -> CGFloat {
        let remaining = event.startDate.timeIntervalSince(date)
        let time = date.timeIntervalSinceReferenceDate

        guard remaining > 30 && remaining <= 120 else {
            return 0
        }

        // Wave: subtle sideways movement
        let fullOffset = CGFloat(sin(time * 3.5)) * 2

        switch effectiveAnimationMode {
        case .full:
            return fullOffset

        case .reduced:
            return fullOffset * 0.35

        case .still:
            return 0
        }
    }

    private func rotation(at date: Date) -> Double {
        let remaining = event.startDate.timeIntervalSince(date)
        let time = date.timeIntervalSinceReferenceDate

        guard remaining > 30 && remaining <= 120 else {
            return 0
        }

        // Wave: playful rocking
        let fullRotation = sin(time * 3.5) * 2.5

        switch effectiveAnimationMode {
        case .full:
            return fullRotation

        case .reduced:
            return fullRotation * 0.35

        case .still:
            return 0
        }
    }

    private func countdownText(at date: Date) -> String {
        let remaining = event.startDate.timeIntervalSince(date)

        // Keep "Starting now" briefly around the exact start time.
        if remaining <= 0 && remaining >= -10 {
            return "Starting now"
        }

        if remaining < 0 {
            let elapsed = Int(abs(remaining))
            let minutes = elapsed / 60
            let seconds = elapsed % 60

            if minutes > 0 && seconds > 0 {
                return "Started \(minutes)m \(seconds)s ago"
            } else if minutes > 0 {
                return "Started \(minutes)m ago"
            } else {
                return "Started \(seconds)s ago"
            }
        }

        let totalSeconds = Int(remaining)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        if minutes > 0 && seconds > 0 {
            return "Starts in \(minutes)m \(seconds)s"
        } else if minutes > 0 {
            return "Starts in \(minutes)m"
        } else {
            return "Starts in \(seconds)s"
        }
    }
    
    private func joinButtonTitle(
        for provider: MeetingProvider,
        at date: Date
    ) -> String {
        if date >= event.startDate {
            return "Join Now"
        }

        switch provider {
        case .googleMeet:
            return "Join Google Meet"

        case .zoom:
            return "Join Zoom"

        case .teams:
            return "Join Teams"

        case .other:
            return "Join Meeting"
        }
    }
    
    private var effectiveAnimationMode: MascotAnimationMode {
        if reduceMotion && mascotAnimationMode == .full {
            return .reduced
        }

        return mascotAnimationMode
    }
}
