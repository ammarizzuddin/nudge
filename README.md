# Nudge

A friendly macOS menu bar companion that nudges you before your next meeting.

Nudge lives quietly in your menu bar, watches your selected calendars, and brings a small animated companion onto your desktop when your next event is approaching. It helps you see what's coming up and get into your meeting without digging through Calendar.

> [!NOTE]
> Nudge is currently under active development.

## ✨ Features

- **Calendar-aware reminders**  
  Automatically detects upcoming events from your macOS calendars.

- **Animated desktop companion**  
  A small mascot appears before your event, with different animations as the meeting gets closer.

- **Live countdown**  
  See exactly how long remains before an event starts.

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
   git clone https://github.com/YOUR_USERNAME/nudge.git
   ```

2. Open the project in Xcode.

3. Select the **Nudge** target.

4. Configure your development team under **Signing & Capabilities** if required.

5. Build and run the app.

6. Grant Calendar access when prompted.

Nudge runs as a menu bar app and does not appear in the Dock.

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

## 🔒 Privacy

Nudge is designed as a native macOS application and reads calendar information through Apple's EventKit APIs.

Nudge does not require your calendar account credentials.

## 🛠️ Built With

- Swift
- SwiftUI
- AppKit
- EventKit
- ServiceManagement

## 🧪 Project Status

Nudge is currently an early-stage personal project and is under active development.

Features, behaviour and UI may change as the app evolves.

## 💡 Why Nudge?

Calendar notifications are easy to miss, especially during focused work.

Nudge takes a different approach: instead of another notification banner, a small desktop companion appears as your meeting approaches, giving you a persistent but friendly reminder of where you need to be next.

## 📄 Licence

No licence has been specified yet.
