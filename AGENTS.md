# AGENTS.md

## Project Overview

Nudge is a native macOS menu bar application written in Swift using SwiftUI
and AppKit.

It monitors calendar events through EventKit and displays a small animated
desktop companion before upcoming events.

Nudge is intended to remain lightweight, native, and privacy-friendly.

## Platform

- macOS 15.0+
- Swift
- SwiftUI
- AppKit where macOS-specific behaviour requires it
- EventKit for Calendar integration
- ServiceManagement for Launch at Login
- No external dependencies unless explicitly approved

## Architecture Guidelines

### Menu Bar

Nudge is a menu-bar-only application.

- Keep `MenuBarExtra` as the primary menu-bar implementation.
- Do not add a Dock icon.
- Do not replace the working SwiftUI menu-bar implementation with
  `NSStatusItem` unless explicitly requested.
- The optional menu-bar countdown must remain compact.

### Calendar

Calendar access is provided through EventKit.

- Do not add direct Google Calendar, Microsoft Graph, or other account
  authentication unless explicitly requested.
- Nudge should use calendars already configured on macOS.
- All-day events must not trigger Nudge.
- Respect the user's selected/excluded calendars.

### Companion Window

The companion uses a reusable AppKit `NSPanel`.

Important:

- Maintain one panel for the application lifetime.
- Reuse the existing panel when the relevant event changes.
- Do not create a new `NSPanel` for every reminder.
- Preserve the existing draggable companion behaviour.
- Preserve multi-Space/full-screen auxiliary behaviour.

Do not reintroduce custom full-screen application detection. A previous
experiment was intentionally removed because reliable detection would have
required additional permissions.

### Reminder Lifecycle

Preserve the existing reminder lifecycle:

1. Detect the next relevant timed calendar event.
2. Show Nudge when the event enters the configured reminder window.
3. Allow Snooze and Dismiss.
4. Escalate the mascot as the event approaches.
5. Play the configured alert sound according to the existing lifecycle.
6. Optionally keep Nudge visible for the configured grace period after the
   event starts.
7. Transition correctly to another event when overlapping or back-to-back
   events occur.

Be especially careful when modifying timers or event selection logic.

Event edits, deletions, calendar changes, snoozes, dismissals, event start
times, grace periods, and alert sounds must continue to work correctly.

### Preview Nudge

`Preview Nudge` is intentionally separate from a real reminder.

Previewing must not:

- mark an event as dismissed;
- create a real snooze;
- alter EventMonitor lifecycle state;
- prevent the real reminder from appearing later.

### Settings

Persist user preferences through `UserDefaults` / `@AppStorage`.

Application defaults should be registered centrally rather than relying on
the implicit zero/false value returned for missing UserDefaults keys.

Current intended defaults include:

- Reminder lead time: 5 minutes
- Post-start grace period: 5 minutes
- Sound: None
- Mascot animation: Full
- Menu-bar countdown: Off

Do not overwrite existing user preferences when registering defaults.

## UI Guidelines

Prefer native macOS behaviour and controls.

- Use SwiftUI for normal application UI.
- Use AppKit where SwiftUI does not provide reliable macOS-specific
  functionality.
- Preserve the lightweight menu-bar utility experience.
- Avoid unnecessary windows, dialogs, or permissions.
- Respect macOS Reduce Motion.
- Keep the companion friendly and unobtrusive.

## Code Guidelines

- Prefer small, focused types.
- Preserve existing working architecture unless a change has a clear
  technical benefit.
- Avoid adding abstractions solely for stylistic reasons.
- Avoid force unwraps where practical.
- Follow Swift concurrency rules.
- Avoid introducing compiler warnings.
- Remove temporary debugging code before completing a task.
- Do not add third-party packages without explicit approval.

## Scope Discipline

When implementing a requested feature or fix:

- Make the smallest coherent change that solves the problem.
- Do not implement unrelated features.
- Do not refactor unrelated working code.
- Do not silently change established UX behaviour.
- If a larger architectural change appears necessary, explain it before
  implementing it.

## Build and Verification

After code changes:

1. Build the Nudge target.
2. Resolve errors introduced by the change.
3. Check for new compiler warnings.
4. Report the files changed.
5. Summarise behavioural changes.
6. Provide relevant manual test cases.

For reminder-related changes, consider testing:

- event outside reminder window;
- event entering reminder window;
- event start;
- post-start grace period;
- dismiss;
- snooze;
- edited event start time;
- deleted event;
- overlapping events;
- back-to-back events;
- excluded calendars;
- Calendar permission changes.

## Git

Do not commit, push, create tags, or modify remote branches unless explicitly
requested.

When a coherent piece of work is complete, suggest an appropriate Conventional
Commit message.

Preferred commit prefixes include:

- `feat:` new functionality
- `fix:` bug fixes
- `refactor:` internal restructuring without behavioural change
- `docs:` documentation
- `chore:` maintenance/configuration
- `test:` tests

Keep commits focused on one logical change.
