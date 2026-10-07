//
//  NudgeSettingsView.swift
//  NudgeApp
//
//  Created by Ammar Rosli on 06/10/2026.
//

import AppKit
import EventKit
import ServiceManagement
import SwiftUI

struct NudgeSettingsView: View {
    @AppStorage("reminderLeadTime")
    private var reminderLeadTime = NudgeDefaults.reminderLeadTime
    
    @AppStorage("eventGracePeriod")
    private var eventGracePeriod = NudgeDefaults.eventGracePeriod
    
    @AppStorage("nudgeSound")
    private var nudgeSound = NudgeDefaults.nudgeSound
    
    @AppStorage("mascotAnimationMode")
    private var mascotAnimationMode: MascotAnimationMode = .full
    
    @AppStorage("showCountdownInMenuBar")
    private var showCountdownInMenuBar = NudgeDefaults.showCountdownInMenuBar

    @State private var launchAtLogin =
        SMAppService.mainApp.status == .enabled
    
    let calendarManager: CalendarManager
    let eventMonitor: EventMonitor
    
    @AppStorage("excludedCalendarIdentifiers")
    private var excludedCalendarIdentifiersData: Data = Data()
    private var excludedCalendarIdentifiers: Set<String> {
        get {
            guard !excludedCalendarIdentifiersData.isEmpty,
                  let identifiers = try? JSONDecoder().decode(
                      Set<String>.self,
                      from: excludedCalendarIdentifiersData
                  ) else {
                return []
            }

            return identifiers
        }

        nonmutating set {
            excludedCalendarIdentifiersData =
                (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    var body: some View {
        Form {
            Section("Reminders") {
                Picker(
                    "Show Nudge",
                    selection: $reminderLeadTime
                ) {
                    Text("1 minute before")
                        .tag(1.0)

                    Text("2 minutes before")
                        .tag(2.0)

                    Text("5 minutes before")
                        .tag(5.0)

                    Text("10 minutes before")
                        .tag(10.0)

                    Text("15 minutes before")
                        .tag(15.0)
                }
                .onChange(of: reminderLeadTime) {
                    eventMonitor.checkNow()
                }
                
                Picker(
                    "Keep Nudge",
                    selection: $eventGracePeriod
                ) {
                    Text("Don't keep")
                        .tag(0.0)

                    Text("1 minute after")
                        .tag(1.0)

                    Text("2 minutes after")
                        .tag(2.0)

                    Text("5 minutes after")
                        .tag(5.0)

                    Text("10 minutes after")
                        .tag(10.0)
                }
                .onChange(of: eventGracePeriod) {
                    eventMonitor.checkNow()
                }
                
                Picker(
                    "Sound",
                    selection: $nudgeSound
                ) {
                    Text("None")
                        .tag("None")

                    Text("Glass")
                        .tag("Glass")

                    Text("Ping")
                        .tag("Ping")

                    Text("Pop")
                        .tag("Pop")

                    Text("Purr")
                        .tag("Purr")

                    Text("Submarine")
                        .tag("Submarine")
                }
                .onChange(of: nudgeSound) {
                    previewSound(nudgeSound)
                }
            }

            Section("General") {
                Toggle(
                    "Launch Nudge at login",
                    isOn: $launchAtLogin
                )
                .onChange(of: launchAtLogin) {
                    updateLaunchAtLogin()
                }
            }
            
            Section("Appearance") {
                Picker(
                    "Mascot animation",
                    selection: $mascotAnimationMode
                ) {
                    ForEach(MascotAnimationMode.allCases) { mode in
                        Text(mode.title)
                            .tag(mode)
                    }
                }
                
                Toggle(
                    "Show event countdown in menu bar",
                    isOn: $showCountdownInMenuBar
                )
            }
            
            Section("Calendars") {
                HStack {
                    Button("Select All") {
                        setAllCalendars(enabled: true)
                    }

                    Button("Deselect All") {
                        setAllCalendars(enabled: false)
                    }

                    Spacer()
                }
                .buttonStyle(.link)
                
                ForEach(
                    calendarManager.calendarsBySource,
                    id: \.source.sourceIdentifier
                ) { group in

                    Section {
                        ForEach(
                            group.calendars,
                            id: \.calendarIdentifier
                        ) { calendar in

                            Toggle(
                                isOn: calendarBinding(for: calendar)
                            ) {
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(calendarColor(calendar))
                                        .frame(width: 8, height: 8)

                                    Text(calendar.title)
                                }
                            }
                        }
                    } header: {
                        Label(
                            group.source.title,
                            systemImage: sourceIcon(for: group.source)
                        )
                    }
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 420, height: 450)
        .navigationTitle("Nudge Settings")
    }

    private func updateLaunchAtLogin() {
        do {
            if launchAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Unable to update launch at login: \(error)")

            // Restore the toggle to the actual system state.
            launchAtLogin =
                SMAppService.mainApp.status == .enabled
        }
    }
    
    private func isCalendarEnabled(_ calendar: EKCalendar) -> Bool {
        !excludedCalendarIdentifiers.contains(calendar.calendarIdentifier)
    }

    private func setCalendar(
        _ calendar: EKCalendar,
        enabled: Bool
    ) {
        var excluded = excludedCalendarIdentifiers

        if enabled {
            excluded.remove(calendar.calendarIdentifier)
        } else {
            excluded.insert(calendar.calendarIdentifier)
        }

        excludedCalendarIdentifiers = excluded

        eventMonitor.checkNow()
    }
    
    private func calendarColor(
        _ calendar: EKCalendar
    ) -> Color {
        guard let nsColor = NSColor(
            cgColor: calendar.cgColor
        ) else {
            return .secondary
        }

        return Color(nsColor: nsColor)
    }
    
    private func sourceIcon(
        for source: EKSource
    ) -> String {
        switch source.sourceType {
        case .exchange:
            return "building.2"

        case .calDAV:
            return "calendar"

        case .mobileMe:
            return "icloud"

        case .local:
            return "macbook"

        case .subscribed:
            return "calendar.badge.plus"

        case .birthdays:
            return "birthday.cake"

        @unknown default:
            return "calendar"
        }
    }
    
    private func calendarBinding(
        for calendar: EKCalendar
    ) -> Binding<Bool> {
        Binding(
            get: {
                isCalendarEnabled(calendar)
            },
            set: { enabled in
                setCalendar(
                    calendar,
                    enabled: enabled
                )
            }
        )
    }
    
    private func setAllCalendars(enabled: Bool) {
        if enabled {
            excludedCalendarIdentifiers = []
        } else {
            excludedCalendarIdentifiers = Set(
                calendarManager.availableCalendars.map(
                    \.calendarIdentifier
                )
            )
        }

        eventMonitor.checkNow()
    }
    
    private func previewSound(_ soundName: String) {
        guard soundName != "None" else {
            return
        }

        NSSound(named: NSSound.Name(soundName))?.play()
    }
}
