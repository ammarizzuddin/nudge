# Nudge

A friendly macOS menu bar companion that nudges you before your next meeting.

Nudge lives quietly in your menu bar, watches your selected calendars, and brings a small animated companion onto your desktop when your next event is approaching. It helps you see what's coming up and get into your meeting without digging through Calendar.

> [!NOTE]
> Nudge `0.1.0` is currently in beta and under active development.

## ✨ Features

- **Calendar-aware reminders**  
  Automatically detects upcoming events from your macOS calendars.

- **Animated desktop companion**  
  A small mascot appears before your event, with different animations as the meeting gets closer.

- **Live countdown**  
  See exactly how long remains before an event starts.

- **At-a-glance menu**
  See the next two events, their start times and calendar, with quick actions for joining meetings, opening locations and viewing Calendar.

- **Meeting link detection**  
  Automatically detects Google Meet, Zoom, Microsoft Teams and other meeting links.

- **One-click joining**  
  Jump directly into an online meeting from Nudge.

- **Location support**  
  For events with a physical location, open the destination directly in Maps.

- **Snooze and dismiss**  
  Snooze a reminder when you need a little more time, or dismiss it completely.

- **Post-start reminders**  
  Optionally keep Nudge visible for a few minutes after an event begins, so a meeting isn't immediately forgotten just because the clock passed its start time.

- **Calendar filtering**  
  Choose which calendars Nudge should pay attention to.

- **Notification sounds**  
  Choose from several macOS sounds or keep Nudge completely silent.

- **Animation preferences**  
  Choose between Full, Reduced and Still mascot animations. Nudge also respects macOS Reduce Motion.

- **Launch at login**  
  Have Nudge start automatically when you sign in to your Mac.

## 🖥️ Requirements

- macOS 15.0 or later
- Calendar access

## 🚀 Getting Started

1. Clone the repository:

   ```bash
   git clone https://github.com/ammarizzuddin/nudge.git
   ```

2. Open the project in Xcode.

3. Select the **Nudge** target.

4. Configure your development team under **Signing & Capabilities** if required.

5. Build and run the app.

6. Complete the welcome screen:
   - Grant Calendar access so Nudge can find upcoming events.
   - Optionally enable launch at login.
   - Optionally enable the menu-bar countdown.

Nudge runs as a menu bar app and does not appear in the Dock.

If Calendar access is denied, use **Open Calendar Privacy Settings…** from the Nudge menu to review the permission in System Settings.

## 📦 Installing a Beta Build

1. Download the notarized `Nudge-<version>.zip` beta artifact.
2. Unzip it and drag **Nudge.app** into the Applications folder.
3. Open Nudge from Applications and complete the welcome screen.

A correctly signed and notarized beta should open normally without bypassing Gatekeeper.

## ⚙️ Settings

Nudge can be customised from **Settings…** in the menu bar.

You can configure:

- How many minutes before an event Nudge appears
- How long Nudge remains after an event starts
- Reminder sound
- Mascot animation level
- Calendars included in reminders
- Launch at login
- Menu bar countdown

## 🗓️ Calendar Integration

Nudge uses Apple's EventKit framework to access calendar events.

Calendar access is used to determine upcoming events and provide relevant meeting information. You can choose which calendars Nudge monitors from Settings.

Nudge ignores all-day events, cancelled events and invitations you have declined. When events overlap or run back-to-back, it transitions to the next event as that event enters your configured reminder window.

## 🔒 Privacy

Nudge is designed as a native macOS application and reads calendar information through Apple's EventKit APIs.

Nudge does not require your calendar account credentials.

Calendar data is processed locally. Nudge does not upload calendar events or require a Nudge account.

## 🛠️ Built With

- Swift
- SwiftUI
- AppKit
- EventKit
- ServiceManagement

## 🧪 Testing

Run the unit tests in Xcode with **Product → Test**, or from Terminal:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcodebuild test \
  -project Nudge.xcodeproj \
  -scheme Nudge \
  -destination 'platform=macOS'
```

The test suite covers reminder and grace-period boundaries, countdown labels, event priority for overlapping or back-to-back events, and meeting-link detection.

## 🩹 Troubleshooting

- **No events appear:** Confirm Calendar access is enabled for Nudge in **System Settings → Privacy & Security → Calendars**, then review the selected calendars in Nudge Settings.
- **Nudge does not launch at login:** Toggle **Launch Nudge at login** off and on again, then verify Nudge under **System Settings → General → Login Items & Extensions**.
- **No menu-bar countdown appears:** Enable it in Nudge Settings and make sure the next event is inside the configured reminder window.
- **A meeting link is missing:** Confirm the event contains a supported Zoom, Microsoft Teams or Google Meet URL in its URL, notes or location field.

## 🧪 Project Status

Nudge is currently an early-stage personal project and is under active development.

Features, behaviour and UI may change as the app evolves.

## 💡 Why Nudge?

Calendar notifications are easy to miss, especially during focused work.

Nudge takes a different approach: instead of another notification banner, a small desktop companion appears as your meeting approaches, giving you a persistent but friendly reminder of where you need to be next.

## 📄 Licence

Nudge is available under the [MIT License](LICENSE).

## 🚢 Releasing

See [the beta release checklist](docs/BETA_RELEASE_CHECKLIST.md) for the archive, notarization, packaging and fresh-Mac verification workflow.
