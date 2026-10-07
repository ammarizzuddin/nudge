import AppKit
import EventKit
import ServiceManagement
import SwiftUI

struct OnboardingView: View {
    let calendarManager: CalendarManager
    let onFinish: () -> Void

    @AppStorage("showCountdownInMenuBar")
    private var showCountdownInMenuBar = NudgeDefaults.showCountdownInMenuBar

    @State private var authorizationStatus: EKAuthorizationStatus
    @State private var launchAtLogin: Bool
    @State private var setupError: String?

    init(
        calendarManager: CalendarManager,
        onFinish: @escaping () -> Void
    ) {
        self.calendarManager = calendarManager
        self.onFinish = onFinish

        _authorizationStatus = State(
            initialValue: calendarManager.authorizationStatus
        )
        _launchAtLogin = State(
            initialValue: SMAppService.mainApp.status == .enabled
        )
    }

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 10) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color("NudgeAccent"))

                Text("Welcome to Nudge")
                    .font(.largeTitle.bold())

                Text(
                    "Nudge watches the calendars already on your Mac and brings a friendly reminder onto your desktop before an event begins."
                )
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 420)
            }

            VStack(spacing: 12) {
                setupRow(
                    title: "Calendar Access",
                    description: calendarDescription,
                    systemImage: calendarSystemImage
                ) {
                    calendarAction
                }

                Divider()

                Toggle(isOn: $launchAtLogin) {
                    setupLabel(
                        title: "Launch at Login",
                        description: "Keep Nudge ready without opening it manually.",
                        systemImage: "power"
                    )
                }
                .toggleStyle(.switch)
                .onChange(of: launchAtLogin) {
                    updateLaunchAtLogin()
                }

                Divider()

                Toggle(isOn: $showCountdownInMenuBar) {
                    setupLabel(
                        title: "Menu Bar Countdown",
                        description: "Show the remaining time when an event is close.",
                        systemImage: "menubar.rectangle"
                    )
                }
                .toggleStyle(.switch)
            }
            .padding(18)
            .background(.regularMaterial)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 14,
                    style: .continuous
                )
            )

            if let setupError {
                Text(setupError)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Button(finishButtonTitle) {
                onFinish()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Text("You can change these choices later from Nudge Settings.")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(32)
        .frame(width: 520, height: 540)
    }

    private var calendarAction: some View {
        Group {
            if authorizationStatus == .notDetermined {
                Button("Allow Access") {
                    requestCalendarAccess()
                }
            } else if authorizationStatus == .fullAccess {
                Label("Connected", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else if authorizationStatus == .restricted {
                Text("Restricted")
                    .foregroundStyle(.secondary)
            } else {
                Button("Open Settings") {
                    openCalendarPrivacySettings()
                }
            }
        }
        .fixedSize()
    }

    private var calendarDescription: String {
        switch authorizationStatus {
        case .fullAccess:
            return "Calendar access is ready. Your events stay on this Mac."
        case .denied:
            return "Access was denied. You can enable it in System Settings."
        case .restricted:
            return "Calendar access is restricted on this Mac."
        default:
            return "Required to find upcoming events. Nudge never asks for your account password."
        }
    }

    private var calendarSystemImage: String {
        authorizationStatus == .fullAccess
            ? "calendar.badge.checkmark"
            : "calendar"
    }

    private var finishButtonTitle: String {
        authorizationStatus == .fullAccess
            ? "Start Using Nudge"
            : "Continue Without Calendar"
    }

    private func setupRow<Accessory: View>(
        title: String,
        description: String,
        systemImage: String,
        @ViewBuilder accessory: () -> Accessory
    ) -> some View {
        HStack(spacing: 14) {
            setupLabel(
                title: title,
                description: description,
                systemImage: systemImage
            )

            Spacer(minLength: 12)

            accessory()
        }
    }

    private func setupLabel(
        title: String,
        description: String,
        systemImage: String
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 20))
                .foregroundStyle(.secondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func requestCalendarAccess() {
        setupError = nil

        Task {
            let granted = await calendarManager.requestAccess()
            authorizationStatus = calendarManager.authorizationStatus

            if !granted && authorizationStatus == .notDetermined {
                setupError = "Nudge couldn’t request Calendar access. Please try again."
            }
        }
    }

    private func updateLaunchAtLogin() {
        setupError = nil

        do {
            if launchAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            launchAtLogin = SMAppService.mainApp.status == .enabled
            setupError = "Nudge couldn’t update the launch-at-login setting."
        }
    }

    private func openCalendarPrivacySettings() {
        guard let url = URL(
            string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars"
        ) else {
            return
        }

        NSWorkspace.shared.open(url)
    }
}
