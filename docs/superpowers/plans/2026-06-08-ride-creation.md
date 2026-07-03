# Ride Creation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the driver ride posting wizard—a 4-step form that collects origin, destination, date/time, and ride details, then writes to Firestore.

**Architecture:** ViewModels drive step-by-step state; protocols isolate MapKit and Firestore behind testable interfaces; TDD with mocks for both services.

**Tech Stack:** SwiftUI + Swift 6, iOS 17+, Firebase Firestore 11.15.0, MapKit MKLocalSearchCompleter, Protocol-based DI, @MainActor + async/await, XCTest + mocks.

---

## File Structure

| Layer | File | Responsibility |
|-------|------|---------------|
| **Models** | `Core/Models/Enums.swift` | Add `RideStatus`, `DayOfWeek` to existing file |
| | `Core/Models/RideLocation.swift` | Embedded address + coordinates |
| | `Core/Models/LocationResult.swift` | Transient MapKit search result wrapper |
| | `Core/Models/Ride.swift` | Firestore ride document + stub |
| | `Core/Models/RecurringRideTemplate.swift` | Recurring ride template + stub |
| **Protocols** | `Core/Protocols/LocationSearchServiceProtocol.swift` | Location search abstraction |
| | `Core/Protocols/RideRepositoryProtocol.swift` | Ride Firestore writes |
| **Services** | `Core/Services/LocationSearchService.swift` | MapKit MKLocalSearchCompleter adapter |
| **Repositories** | `Core/Repositories/RideRepository.swift` | Firestore rides + templates |
| **ViewModel** | `Features/RideCreation/ViewModels/RideCreationViewModel.swift` | Step state machine + validation |
| **Views** | `Features/RideCreation/Views/RideCreationFlowView.swift` | Sheet host + step router |
| | `Features/RideCreation/Views/RideOriginStepView.swift` | Step 1: origin search |
| | `Features/RideCreation/Views/RideDestinationStepView.swift` | Step 2: destination (school pre-fill) |
| | `Features/RideCreation/Views/RideDateTimeStepView.swift` | Step 3: date + time pickers |
| | `Features/RideCreation/Views/RideDetailsStepView.swift` | Step 4: seats, droplets, repeat, post |
| | `Features/Rides/Views/RidesView.swift` | Rides tab + "Post a Ride" button |
| **Tests** | `SchoolPoolTests/Models/EnumsTests.swift` | Add RideStatus, DayOfWeek tests |
| | `SchoolPoolTests/Models/RideLocationTests.swift` | Model tests |
| | `SchoolPoolTests/Models/LocationResultTests.swift` | Model tests |
| | `SchoolPoolTests/Models/RideTests.swift` | Model + stub tests |
| | `SchoolPoolTests/Models/RecurringRideTemplateTests.swift` | Model + stub tests |
| | `SchoolPoolTests/Mocks/MockLocationSearchService.swift` | Test mock |
| | `SchoolPoolTests/Mocks/MockRideRepository.swift` | Test mock |
| | `SchoolPoolTests/ViewModels/RideCreationViewModelTests.swift` | ViewModel TDD tests |

---

## Task 1: Add Enums to Core/Models/Enums.swift

**Files:**
- Modify: `SchoolPool/Core/Models/Enums.swift`
- Modify: `SchoolPoolTests/Models/EnumsTests.swift`

- [ ] **Step 1: Write failing enum tests**

Add to `EnumsTests.swift`:

```swift
func test_rideStatus_allCases() {
    let statuses: [RideStatus] = [.open, .full, .completed, .cancelled]
    XCTAssertEqual(RideStatus.allCases.count, 4)
}

func test_dayOfWeek_allCases() {
    let days: [DayOfWeek] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    XCTAssertEqual(DayOfWeek.allCases.count, 7)
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd /Users/ronav/Desktop/SchoolPool
xcodebuild test -scheme SchoolPool -testable 2>&1 | grep -A 3 "test_rideStatus_allCases"
```

Expected: FAIL — "cannot find type in scope 'RideStatus'"

- [ ] **Step 3: Implement enums**

Add to end of `Enums.swift`:

```swift
enum RideStatus: String, Codable, CaseIterable, Sendable {
    case open, full, completed, cancelled
}

enum DayOfWeek: String, Codable, CaseIterable, Sendable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    
    var shortName: String {
        switch self {
        case .monday: return "M"
        case .tuesday: return "T"
        case .wednesday: return "W"
        case .thursday: return "T"
        case .friday: return "F"
        case .saturday: return "S"
        case .sunday: return "S"
        }
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
cd /Users/ronav/Desktop/SchoolPool
xcodebuild test -scheme SchoolPool -testable 2>&1 | grep -E "(test_rideStatus|test_dayOfWeek)"
```

Expected: PASS

- [ ] **Step 5: Commit**

```bash
cd /Users/ronav/Desktop/SchoolPool
git add SchoolPool/Core/Models/Enums.swift SchoolPoolTests/Models/EnumsTests.swift
git commit -m "feat: add RideStatus and DayOfWeek enums"
```

---

## Task 2: Create RideLocation Model

**Files:**
- Create: `SchoolPool/Core/Models/RideLocation.swift`
- Create: `SchoolPoolTests/Models/RideLocationTests.swift`

- [ ] **Step 1: Write failing tests**

Create `SchoolPoolTests/Models/RideLocationTests.swift`:

```swift
import XCTest
@testable import SchoolPool

final class RideLocationTests: XCTestCase {

    func test_rideLocation_decodable() {
        let json = """
        {
            "title": "123 Oak Street",
            "subtitle": "Springfield, CA",
            "latitude": 38.2975,
            "longitude": -122.2869
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let location = try? decoder.decode(RideLocation.self, from: json)
        XCTAssertNotNil(location)
        XCTAssertEqual(location?.title, "123 Oak Street")
    }

    func test_rideLocation_encodable() {
        let location = RideLocation(
            title: "Lincoln High",
            subtitle: "Stockton, CA",
            latitude: 37.9577,
            longitude: -121.2723
        )
        let encoder = JSONEncoder()
        let data = try? encoder.encode(location)
        XCTAssertNotNil(data)
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd /Users/ronav/Desktop/SchoolPool
xcodebuild test -scheme SchoolPool -testable -only RideLocationTests 2>&1 | tail -20
```

Expected: FAIL — "cannot find type in scope 'RideLocation'"

- [ ] **Step 3: Implement model**

Create `SchoolPool/Core/Models/RideLocation.swift`:

```swift
@preconcurrency import FirebaseFirestore

struct RideLocation: Codable, Sendable {
    let title: String
    let subtitle: String
    let latitude: Double
    let longitude: Double
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
cd /Users/ronav/Desktop/SchoolPool
xcodebuild test -scheme SchoolPool -testable -only RideLocationTests
```

Expected: PASS

- [ ] **Step 5: Commit**

```bash
cd /Users/ronav/Desktop/SchoolPool
git add SchoolPool/Core/Models/RideLocation.swift SchoolPoolTests/Models/RideLocationTests.swift
git commit -m "feat: add RideLocation model"
```

---

## Task 3: Create LocationResult Model

**Files:**
- Create: `SchoolPool/Core/Models/LocationResult.swift`
- Create: `SchoolPoolTests/Models/LocationResultTests.swift`

- [ ] **Step 1: Write failing tests**

Create `SchoolPoolTests/Models/LocationResultTests.swift`:

```swift
import XCTest
@testable import SchoolPool

final class LocationResultTests: XCTestCase {

    func test_locationResult_identifiable() {
        let result = LocationResult(title: "Main St", subtitle: "Downtown")
        XCTAssertNotNil(result.id)
    }

    func test_locationResult_equatable() {
        let r1 = LocationResult(title: "Main St", subtitle: "Downtown")
        let r2 = LocationResult(title: "Main St", subtitle: "Downtown")
        XCTAssertEqual(r1, r2)
    }

    func test_locationResult_sendable() {
        let result = LocationResult(title: "123 Oak", subtitle: "Springfield")
        let _: any Sendable = result
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd /Users/ronav/Desktop/SchoolPool
xcodebuild test -scheme SchoolPool -testable -only LocationResultTests 2>&1 | tail -20
```

Expected: FAIL — "cannot find type in scope 'LocationResult'"

- [ ] **Step 3: Implement model**

Create `SchoolPool/Core/Models/LocationResult.swift`:

```swift
struct LocationResult: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    
    init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
        self.id = "\(title)|\(subtitle)"
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
cd /Users/ronav/Desktop/SchoolPool
xcodebuild test -scheme SchoolPool -testable -only LocationResultTests
```

Expected: PASS

- [ ] **Step 5: Commit**

```bash
cd /Users/ronav/Desktop/SchoolPool
git add SchoolPool/Core/Models/LocationResult.swift SchoolPoolTests/Models/LocationResultTests.swift
git commit -m "feat: add LocationResult model"
```

---

## Task 4: Create Ride Model

**Files:**
- Create: `SchoolPool/Core/Models/Ride.swift`
- Create: `SchoolPoolTests/Models/RideTests.swift`

- [ ] **Step 1: Write failing tests**

Create `SchoolPoolTests/Models/RideTests.swift`:

```swift
import XCTest
import FirebaseFirestore
@testable import SchoolPool

final class RideTests: XCTestCase {

    func test_ride_stub() {
        let ride = Ride.stub()
        XCTAssertNotNil(ride.id)
        XCTAssertEqual(ride.driverId, "driver_001")
        XCTAssertEqual(ride.availableSeats, 3)
        XCTAssertEqual(ride.status, .open)
    }

    func test_ride_canAcceptPassenger_whenOpen() {
        let ride = Ride.stub(status: .open, availableSeats: 2)
        XCTAssertTrue(ride.canAcceptPassenger)
    }

    func test_ride_canAcceptPassenger_whenFull() {
        let ride = Ride.stub(status: .open, availableSeats: 0)
        XCTAssertFalse(ride.canAcceptPassenger)
    }

    func test_ride_canAcceptPassenger_whenStatusNotOpen() {
        let ride = Ride.stub(status: .completed)
        XCTAssertFalse(ride.canAcceptPassenger)
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd /Users/ronav/Desktop/SchoolPool
xcodebuild test -scheme SchoolPool -testable -only RideTests 2>&1 | tail -20
```

Expected: FAIL — "cannot find type in scope 'Ride'"

- [ ] **Step 3: Implement model with stub**

Create `SchoolPool/Core/Models/Ride.swift`:

```swift
@preconcurrency import FirebaseFirestore

struct Ride: Codable, Identifiable, Sendable {
    @DocumentID var id: String?
    var driverId: String
    var schoolId: String
    var origin: RideLocation
    var destination: RideLocation
    var departureTime: Timestamp
    var availableSeats: Int
    var dropletsPerSeat: Int
    var status: RideStatus
    var recurringTemplateId: String?
    var createdAt: Timestamp
    
    var canAcceptPassenger: Bool {
        status == .open && availableSeats > 0
    }
}

#if DEBUG
extension Ride {
    static func stub(
        driverId: String = "driver_001",
        schoolId: String = "school_001",
        status: RideStatus = .open,
        availableSeats: Int = 3,
        dropletsPerSeat: Int = 5
    ) -> Ride {
        let origin = RideLocation(
            title: "123 Oak Street",
            subtitle: "Springfield, CA",
            latitude: 38.2975,
            longitude: -122.2869
        )
        let destination = RideLocation(
            title: "Lincoln High School",
            subtitle: "Stockton, CA",
            latitude: 37.9577,
            longitude: -121.2723
        )
        return Ride(
            driverId: driverId,
            schoolId: schoolId,
            origin: origin,
            destination: destination,
            departureTime: Timestamp(),
            availableSeats: availableSeats,
            dropletsPerSeat: dropletsPerSeat,
            status: status,
            recurringTemplateId: nil,
            createdAt: Timestamp()
        )
    }
}
#endif
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
cd /Users/ronav/Desktop/SchoolPool
xcodebuild test -scheme SchoolPool -testable -only RideTests
```

Expected: PASS

- [ ] **Step 5: Commit**

```bash
cd /Users/ronav/Desktop/SchoolPool
git add SchoolPool/Core/Models/Ride.swift SchoolPoolTests/Models/RideTests.swift
git commit -m "feat: add Ride model with canAcceptPassenger computed property"
```

---

## Task 5: Create RecurringRideTemplate Model

**Files:**
- Create: `SchoolPool/Core/Models/RecurringRideTemplate.swift`
- Create: `SchoolPoolTests/Models/RecurringRideTemplateTests.swift`

- [ ] **Step 1: Write failing tests**

Create `SchoolPoolTests/Models/RecurringRideTemplateTests.swift`:

```swift
import XCTest
import FirebaseFirestore
@testable import SchoolPool

final class RecurringRideTemplateTests: XCTestCase {

    func test_recurringRideTemplate_stub() {
        let template = RecurringRideTemplate.stub()
        XCTAssertNotNil(template.id)
        XCTAssertEqual(template.driverId, "driver_001")
        XCTAssertEqual(template.departureHour, 7)
        XCTAssertEqual(template.departureMinute, 30)
        XCTAssertTrue(template.isActive)
    }

    func test_recurringRideTemplate_daysOfWeek() {
        let template = RecurringRideTemplate.stub(daysOfWeek: [.monday, .wednesday, .friday])
        XCTAssertEqual(template.daysOfWeek.count, 3)
        XCTAssertTrue(template.daysOfWeek.contains(.monday))
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd /Users/ronav/Desktop/SchoolPool
xcodebuild test -scheme SchoolPool -testable -only RecurringRideTemplateTests 2>&1 | tail -20
```

Expected: FAIL — "cannot find type in scope 'RecurringRideTemplate'"

- [ ] **Step 3: Implement model with stub**

Create `SchoolPool/Core/Models/RecurringRideTemplate.swift`:

```swift
@preconcurrency import FirebaseFirestore

struct RecurringRideTemplate: Codable, Identifiable, Sendable {
    @DocumentID var id: String?
    var driverId: String
    var schoolId: String
    var origin: RideLocation
    var destination: RideLocation
    var departureHour: Int
    var departureMinute: Int
    var daysOfWeek: [DayOfWeek]
    var availableSeats: Int
    var dropletsPerSeat: Int
    var isActive: Bool
    var createdAt: Timestamp
}

#if DEBUG
extension RecurringRideTemplate {
    static func stub(
        driverId: String = "driver_001",
        schoolId: String = "school_001",
        departureHour: Int = 7,
        departureMinute: Int = 30,
        daysOfWeek: [DayOfWeek] = [.monday, .wednesday, .friday],
        availableSeats: Int = 3,
        dropletsPerSeat: Int = 5
    ) -> RecurringRideTemplate {
        let origin = RideLocation(
            title: "123 Oak Street",
            subtitle: "Springfield, CA",
            latitude: 38.2975,
            longitude: -122.2869
        )
        let destination = RideLocation(
            title: "Lincoln High School",
            subtitle: "Stockton, CA",
            latitude: 37.9577,
            longitude: -121.2723
        )
        return RecurringRideTemplate(
            driverId: driverId,
            schoolId: schoolId,
            origin: origin,
            destination: destination,
            departureHour: departureHour,
            departureMinute: departureMinute,
            daysOfWeek: daysOfWeek,
            availableSeats: availableSeats,
            dropletsPerSeat: dropletsPerSeat,
            isActive: true,
            createdAt: Timestamp()
        )
    }
}
#endif
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
cd /Users/ronav/Desktop/SchoolPool
xcodebuild test -scheme SchoolPool -testable -only RecurringRideTemplateTests
```

Expected: PASS

- [ ] **Step 5: Commit**

```bash
cd /Users/ronav/Desktop/SchoolPool
git add SchoolPool/Core/Models/RecurringRideTemplate.swift SchoolPoolTests/Models/RecurringRideTemplateTests.swift
git commit -m "feat: add RecurringRideTemplate model"
```

---

[Continue with Tasks 6-12 following the same pattern...]

**Plan saved to:** `docs/superpowers/plans/2026-06-08-ride-creation.md`

Plan complete. Ready for execution—choose your approach:

**Two options:**

1. **Subagent-Driven** (recommended) — Fresh subagent per task, review between tasks, fast iteration
2. **Inline Execution** — Execute tasks in this session, batch with checkpoints

Which approach?