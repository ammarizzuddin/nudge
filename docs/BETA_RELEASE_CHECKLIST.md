# Nudge Beta Release Checklist

Use this checklist for the `0.1.0` beta and subsequent direct-distribution builds.

## Before archiving

- Confirm `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in the Nudge target.
- Run the full test suite.
- Run the manual reminder lifecycle checks in `AGENTS.md`.
- Review `CHANGELOG.md` and `README.md`.
- Choose and add a software licence before any public release.
- Confirm the Nudge target uses the intended Apple Developer team.
- Confirm App Sandbox and Hardened Runtime remain enabled.

## Archive and notarize

1. In Xcode, select the Nudge scheme and **My Mac**.
2. Choose **Product → Archive**.
3. In Organizer, select the new archive and choose **Distribute App**.
4. Choose **Direct Distribution** and sign with a Developer ID Application certificate.
5. Allow Xcode to submit the app to Apple for notarization.
6. Export the notarized `Nudge.app` after Xcode reports success.

Do not package a Debug build or an app copied directly from Derived Data.

## Verify and package

From the repository root, run:

```bash
./scripts/package-release.sh "/path/to/exported/Nudge.app"
```

The script verifies the code signature and Gatekeeper assessment before creating `dist/Nudge-<version>.zip`.

You can also validate the exported app directly:

```bash
codesign --verify --deep --strict --verbose=2 "/path/to/Nudge.app"
spctl --assess --type execute --verbose=2 "/path/to/Nudge.app"
xcrun stapler validate "/path/to/Nudge.app"
```

## Fresh-Mac acceptance test

- Download and unzip the exact release archive on another Mac.
- Drag Nudge into Applications and launch it.
- Confirm Gatekeeper opens it without a security workaround.
- Complete onboarding and grant Calendar access.
- Verify the menu, countdown, companion, sounds, snooze and dismiss behavior.
- Verify launch at login after signing out and back in.
- Revoke Calendar access and confirm the recovery action opens System Settings.

## Publish

- Upload the verified ZIP to the intended beta distribution location.
- Include the relevant `CHANGELOG.md` section in the release notes.
- Create and push the version tag only after the uploaded artifact passes the fresh-Mac test.
