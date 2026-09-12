<img width="407" height="141" alt="Screenshot 2026-09-05 at 5 03 52 PM" src="https://github.com/user-attachments/assets/3f45cce9-def5-49a6-b2c4-010e6fd2e616" />

# SchoolPool

SchoolPool is a native iOS carpooling app for school communities. Students and parents post and join rides to school, chat, and rate each other after the trip.

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
