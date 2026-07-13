# SchoolPool

A native iOS carpooling app for school communities — students and parents post and join rides to school, chat, and rate each other after the trip.

Built with SwiftUI + Swift 6 (iOS 17+), Firebase (Auth, Firestore, Messaging), and Google Sign-In. Runs entirely on Firebase's free **Spark** plan — no paid Cloud Functions or Storage required.

## Features

- Ride creation, discovery, and search (school-scoped)
- Seat requests with driver accept/decline
- Live ride status (open → in progress → completed/cancelled)
- Per-ride chat
- Post-ride ratings
- Trip history
- Student ID verification with admin review
- Local notifications for ride status changes and new messages

## Try it — download a build

Prebuilt iOS Simulator builds are attached to each [Release](../../releases). No Apple Developer account or code signing needed — Simulator builds run unsigned.

1. Download `SchoolPool-Simulator.zip` from the latest release and unzip it.
2. Open **Simulator.app** (ships with Xcode, or `xcrun simctl boot "iPhone 16"` from Terminal).
3. Drag `SchoolPool.app` onto the Simulator window, then tap the icon to launch.

This build points at a shared demo Firebase project seeded with sample data — good for trying the app, not for real use. To run your own backend, build from source below.

## Build from source

**Requirements:** Xcode 16.2+, iOS 17+ simulator or device.

```bash
git clone https://github.com/dmdandronav/SchoolPool.git
cd SchoolPool
open SchoolPool.xcodeproj
```

Press **⌘R** to build and run on a simulator. The repo includes a working `GoogleService-Info.plist` pointed at a shared demo Firebase project, so it runs out of the box.

### Using your own Firebase project

1. Create a project at [console.firebase.google.com](https://console.firebase.google.com) (free Spark plan is enough).
2. Enable **Authentication** (Google + Email/Password), and **Firestore Database**.
3. Add an iOS app with bundle ID `com.ronavgupta.SchoolPool` (or update `PRODUCT_BUNDLE_IDENTIFIER` in the Xcode project to your own), download the generated `GoogleService-Info.plist`, and replace `SchoolPool/GoogleService-Info.plist` with it.
4. Deploy the security rules and indexes from the companion backend repo:
   ```bash
   firebase deploy --only firestore:rules,firestore:indexes --project <your-project-id>
   ```
5. Build and run.

Cloud Storage and Cloud Functions are **not required** — ID verification and notifications work without them (see [`docs/superpowers/specs`](docs/superpowers) for design notes). They're an optional upgrade path if you later move to a Blaze-plan project.

## Testing

```bash
xcodebuild test -scheme SchoolPool -destination 'platform=iOS Simulator,name=iPhone 16'
```

94 unit tests across models, services, and view models via protocol-based mocks.

## License

No license file yet — all rights reserved by default until one is added.
