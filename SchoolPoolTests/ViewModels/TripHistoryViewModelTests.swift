import XCTest
@testable import SchoolPool
@preconcurrency import FirebaseFirestore

@MainActor
final class TripHistoryViewModelTests: XCTestCase {

    private func seededRepo() -> MockRideRepository {
        let repo = MockRideRepository()
        var drove = Ride.stub(driverId: "me", status: .completed,
                              departureTime: Timestamp(date: Date().addingTimeInterval(-7200)))
        drove.id = "drove"
        var rode = Ride.stub(driverId: "other", status: .completed, passengerIds: ["me"],
                             departureTime: Timestamp(date: Date().addingTimeInterval(-3600)))
        rode.id = "rode"
        var upcoming = Ride.stub(driverId: "me", status: .open,
                                 departureTime: Timestamp(date: Date().addingTimeInterval(3600)))
        upcoming.id = "upcoming"
        var cancelled = Ride.stub(driverId: "me", status: .cancelled,
                                  departureTime: Timestamp(date: Date().addingTimeInterval(-1000)))
        cancelled.id = "cancelled"
        repo.rides = ["drove": drove, "rode": rode, "upcoming": upcoming, "cancelled": cancelled]
        return repo
    }

    func test_load_includesFinishedDriverAndPassengerRides() async {
        let vm = TripHistoryViewModel(currentUserId: "me", rideRepo: seededRepo())
        await vm.load()

        let ids = Set(vm.trips.map { $0.id })
        XCTAssertTrue(ids.contains("drove"))
        XCTAssertTrue(ids.contains("rode"))
        XCTAssertTrue(ids.contains("cancelled"))
    }

    func test_load_excludesUpcomingRides() async {
        let vm = TripHistoryViewModel(currentUserId: "me", rideRepo: seededRepo())
        await vm.load()

        XCTAssertFalse(vm.trips.contains { $0.id == "upcoming" })
    }

    func test_load_deduplicatesRides() async {
        let repo = MockRideRepository()
        // A ride where the user is both driver and (erroneously) passenger should appear once.
        var ride = Ride.stub(driverId: "me", status: .completed, passengerIds: ["me"])
        ride.id = "dup"
        repo.rides = ["dup": ride]

        let vm = TripHistoryViewModel(currentUserId: "me", rideRepo: repo)
        await vm.load()

        XCTAssertEqual(vm.trips.count, 1)
    }

    func test_load_sortsMostRecentFirst() async {
        let vm = TripHistoryViewModel(currentUserId: "me", rideRepo: seededRepo())
        await vm.load()
        // "rode" (-1h) is more recent than "drove" (-2h)
        let rodeIndex = vm.trips.firstIndex { $0.id == "rode" }
        let droveIndex = vm.trips.firstIndex { $0.id == "drove" }
        XCTAssertNotNil(rodeIndex)
        XCTAssertNotNil(droveIndex)
        XCTAssertLessThan(rodeIndex!, droveIndex!)
    }

    func test_roleLabel_reflectsDriverOrPassenger() async {
        let vm = TripHistoryViewModel(currentUserId: "me", rideRepo: seededRepo())
        await vm.load()
        let drove = vm.trips.first { $0.id == "drove" }!
        let rode = vm.trips.first { $0.id == "rode" }!
        XCTAssertEqual(vm.role(for: drove), .driver)
        XCTAssertEqual(vm.role(for: rode), .passenger)
    }

    func test_load_setsErrorOnFailure() async {
        let repo = MockRideRepository()
        repo.fetchError = MockError.intentional
        let vm = TripHistoryViewModel(currentUserId: "me", rideRepo: repo)
        await vm.load()
        XCTAssertNotNil(vm.errorMessage)
    }
}
