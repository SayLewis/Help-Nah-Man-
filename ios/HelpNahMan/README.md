# Help Nah Man for iOS

Native SwiftUI companion app for the Help Nah Man community noticeboard.

## Requirements

- Xcode 16 or newer
- iOS 17 or newer
- An Apple development team for installation on a physical device

## Run the app

1. Open `HelpNahMan.xcodeproj` in Xcode.
2. Select the `HelpNahMan` scheme and an iPhone simulator.
3. In Signing & Capabilities, choose your Apple development team if Xcode requests it.
4. Build and run.

The first version is offline-first. Notices, bookmarks and participation counts are stored in `UserDefaults` on the device.

## App Intents

The app exposes three actions through Siri, Spotlight and Shortcuts:

- **Find ways to help** — opens Discover with an optional volunteer, event or donation filter.
- **Post a community notice** — opens the native notice composer with a preselected type.
- **Support an opportunity** — registers interest inline using a queryable `OpportunityEntity`.

Test them after launching the app once: open Shortcuts, create a shortcut, choose Apps, then choose Help Nah Man.

## Deep links

- `helpnahman://discover`
- `helpnahman://post`
- `helpnahman://notice/<UUID>`
