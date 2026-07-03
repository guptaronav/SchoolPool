# Ride Creation — Design Spec

**Date:** 2026-06-08  
**Feature:** #1 — Driver posts a ride  
**Status:** Approved

---

## Overview

Drivers post rides through a 4-step wizard that collects origin, destination, date/time, and ride details (seats, droplets, optional weekly recurrence). The wizard matches the existing `OnboardingViewModel` step-enum pattern and persists rides to Firestore.

---

## Data Model

### `rides` collection

```
rides/{rideId}
  id:                  String          // @DocumentID
  driverId:            String          // Auth UID
  schoolId:            String
  origin:              RideLocation    // embedded struct
  destination:         RideLocation    // embedded struct
  departureTime:       Timestamp
  availableSeats:      Int             // 1–6
  dropletsPerSeat:     Int             // 0–20
  status:              RideStatus      // .open | .full | .completed | .cancelled
  recurringTemplateId: String?         // nil for one-off rides
  createdAt:           Timestamp
```

### `recurringRideTemplates` collection

```
recurringRideTemplates/{templateId}
  id:                  String          // @DocumentID
  driverId:            String
  schoolId:            String
  origin:              RideLocation
  destination:         RideLocation
  departureHour:       Int             // 0–23
  departureMinute:     Int             // 0–59
  daysOfWeek:          [DayOfWeek]     // [.monday, .wednesday, .friday]
  availableSeats:      Int
  dropletsPerSeat:     Int
  isActive:            Bool
  createdAt:           Timestamp
```

### `RideLocation` (embedded struct)

```swift
struct RideLocation: Codable, Sendable {
    let title: String          // human-readable label
    let subtitle: String       // secondary address line
    let latitude: Double
    let longitude: Double
}
```

### Supporting types

- `RideStatus` enum: `.open`, `.full`, `.completed`, `.cancelled`
- `DayOfWeek` enum: `.monday` … `.sunday`
- `LocationResult` (transient, not persisted): wraps `MKLocalSearchCompletion` into `{ title, subtitle, coordinate }`

---

## Architecture

### New protocols

```swift
// Core/Protocols/LocationSearchServiceProtocol.swift
protocol LocationSearchServiceProtocol: Sendable {
    func search(query: String) async -> [LocationResult]
    func resolve(_ result: LocationResult) async throws -> CLLocationCoordinate2D
}

// Core/Protocols/RideRepositoryProtocol.swift
protocol RideRepositoryProtocol: Sendable {
    func createRide(_ ride: Ride) async throws
    func createRecurringTemplate(_ template: RecurringRideTemplate) async throws
}
```

### New concrete types

| Layer | File | Responsibility |
|-------|------|---------------|
| Model | `Core/Models/Ride.swift` | Firestore-mapped ride document |
| Model | `Core/Models/RecurringRideTemplate.swift` | Template for recurring rides |
| Model | `Core/Models/RideLocation.swift` | Embedded location struct |
| Model | `Core/Models/Enums.swift` | Add `RideStatus`, `DayOfWeek` to existing file |
| Model | `Core/Models/LocationResult.swift` | Transient MapKit result wrapper |
| Service | `Core/Services/LocationSearchService.swift` | MapKit `MKLocalSearchCompleter` adapter |
| Repository | `Core/Repositories/RideRepository.swift` | Firestore `rides` + `recurringRideTemplates` |
| ViewModel | `Features/RideCreation/ViewModels/RideCreationViewModel.swift` | Step enum, validation, Firestore write |
| View | `Features/RideCreation/Views/RideCreationFlowView.swift` | Sheet host, step routing |
| View | `Features/RideCreation/Views/RideOriginStepView.swift` | Step 1 |
| View | `Features/RideCreation/Views/RideDestinationStepView.swift` | Step 2 |
| View | `Features/RideCreation/Views/RideDateTimeStepView.swift` | Step 3 |
| View | `Features/RideCreation/Views/RideDetailsStepView.swift` | Step 4 + post action |

### Dependency injection

`RideCreationViewModel` takes `LocationSearchServiceProtocol` and `RideRepositoryProtocol` in its initializer, matching the existing pattern (e.g. `AuthViewModel` taking `AuthServiceProtocol`).

---

## Wizard Steps

The `Step` enum inside `RideCreationViewModel`:

```swift
enum Step { case origin, destination, dateTime, details }
```

### Step 1 — Origin
- MapKit `MKLocalSearchCompleter` drives live search results
- Selecting a result stores a `LocationResult`; "Next" becomes enabled
- Back from step 2 returns here with the previously selected value preserved

### Step 2 — Destination
- Driver's school address is pre-filled from `schoolId` (looked up from `SchoolRepository`)
- Driver may clear the pre-fill and search a custom address
- "Next" enabled once a destination is set

### Step 3 — Date & Time
- Two native `DatePicker` controls: `.graphical` for date, `.wheels` for time
- Validation: `departureTime` must be ≥ 30 minutes from `Date.now`; "Next" disabled until valid
- Inline message "Must be at least 30 min from now" shown on invalid state

### Step 4 — Details + Post
- `Stepper` for available seats (1–6, default 2)
- `Stepper` for droplets per seat (0–20, default 5)
- `Toggle` "Repeat weekly" — when on, reveals a row of day-of-week pill buttons (M T W T F S S); at least one day must be selected before posting
- "Post Ride" button triggers `postRide()` on the ViewModel

---

## ViewModel State Machine

```swift
@MainActor
final class RideCreationViewModel: ObservableObject {
    @Published var step: Step = .origin
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var didPost = false   // triggers sheet dismissal

    // per-step state
    @Published var originQuery = ""
    @Published var originResults: [LocationResult] = []
    @Published var selectedOrigin: LocationResult?

    @Published var destinationQuery = ""
    @Published var destinationResults: [LocationResult] = []
    @Published var selectedDestination: LocationResult?

    @Published var departureTime = Date()  // validated ≥ 30 min ahead
    var isDateTimeValid: Bool { departureTime >= Date().addingTimeInterval(30 * 60) }

    @Published var availableSeats = 2
    @Published var dropletsPerSeat = 5
    @Published var isRecurring = false
    @Published var selectedDays: Set<DayOfWeek> = []

    func next() { /* advance step */ }
    func back() { /* retreat step */ }
    func postRide() async { /* write to Firestore */ }
}
```

`postRide()` creates:
1. A `Ride` document in `rides/`
2. If `isRecurring` is true: a `RecurringRideTemplate` document in `recurringRideTemplates/`

---

## Navigation

`MainTabView` replaces the `Text("Rides")` placeholder with a `RidesView`. A "Post a Ride" button in `RidesView` presents `RideCreationFlowView` as a `.sheet`. The sheet dismisses when `didPost` becomes `true`.

The sheet is only offered when `currentUser.canDrive == true` (i.e., `role == .driver && verificationStatus == .verified`).

---

## Error Handling

All errors surface as `errorMessage: String?` on the ViewModel, consistent with the existing pattern.

| Scenario | Behaviour |
|----------|-----------|
| Location search fails | `errorMessage` shown inline below the search field; results list clears |
| Departure time in the past / < 30 min | Inline validation label on step 3; "Next" disabled |
| Firestore write fails | `errorMessage` on step 4; loading spinner stops; user may retry |
| No internet | Same Firestore error path; message: "Couldn't post ride. Check your connection." |
| Driver not verified | "Post a Ride" button hidden; `canDrive` checked before presenting sheet |

---

## Testing

### Mocks

- `MockLocationSearchService` — returns a configurable `[LocationResult]`; supports injectable errors
- `MockRideRepository` — in-memory store; tracks `createRide` / `createRecurringTemplate` call counts; supports injectable errors

### `RideCreationViewModelTests`

| Test | What it verifies |
|------|-----------------|
| `testNextAdvancesStep` | `.origin → .destination → .dateTime → .details` |
| `testBackRevertsStep` | `.destination → .origin` preserves selected origin |
| `testNextDisabledWithoutOrigin` | `selectedOrigin == nil` blocks advance |
| `testDateTimeValidation_tooSoon` | `isDateTimeValid` false when < 30 min ahead |
| `testDateTimeValidation_valid` | `isDateTimeValid` true when ≥ 30 min ahead |
| `testPostRide_success` | `didPost == true`, ride doc created in mock repo |
| `testPostRide_recurringCreatesTemplate` | Template doc created when `isRecurring` |
| `testPostRide_firestoreError_setsErrorMessage` | `errorMessage` non-nil on repo throw |

### `RideTests`

- `testStub` — model initialises cleanly
- `testCanAcceptPassenger` — returns true when `status == .open && availableSeats > 0`

### `LocationResultTests`

- Basic struct equality and property access

**Coverage target:** 80%+ on ViewModel and model layer.
