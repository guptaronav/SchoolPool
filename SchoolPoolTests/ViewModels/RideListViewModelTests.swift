import XCTest
@testable import SchoolPool
@preconcurrency import FirebaseFirestore

@MainActor
final class RideListViewModelTests: XCTestCase {

    private func seedRepo() -> MockRideRepository {
        let repo = MockRideRepository()
        var morning = Ride.stub(driverId: "d1", departureTime: Timestamp(date: Date().addingTimeInterval(3600)))
        morning.id = "ride_morning"
        var evening = Ride.stub(driverId: "d2", departureTime: Timestamp(date: Date().addingTimeInterval(7200)))
        evening.id = "ride_evening"
        evening.destination = RideLocation(title: "Downtown Library", subtitle: "Stockton, CA", latitude: 37.96, longitude: -121.29)
        var otherSchool = Ride.stub(driverId: "d3", schoolId: "school_999")
        otherSchool.id = "ride_other"
        repo.rides = [
            "ride_morning": morning,
            "ride_evening": evening,
            "ride_other": otherSchool
        ]
        return repo
    }

    func test_load_fetchesOnlyOwnSchoolOpenRides_sortedByDeparture() async {
        let vm = RideListViewModel(schoolId: "school_001", currentUserId: "me", rideRepo: seedRepo())
        await vm.load()

        XCTAssertEqual(vm.rides.count, 2)
        XCTAssertEqual(vm.rides.first?.id, "ride_morning")
    }

    func test_load_excludesOwnRidesFromDiscovery() async {
        let vm = RideListViewModel(schoolId: "school_001", currentUserId: "d1", rideRepo: seedRepo())
        await vm.load()

        XCTAssertEqual(vm.rides.count, 1)
        XCTAssertEqual(vm.rides.first?.id, "ride_evening")
    }

    func test_searchText_filtersByLocationTitle() async {
        let vm = RideListViewModel(schoolId: "school_001", currentUserId: "me", rideRepo: seedRepo())
        await vm.load()

        vm.searchText = "library"
        XCTAssertEqual(vm.filteredRides.count, 1)
        XCTAssertEqual(vm.filteredRides.first?.id, "ride_evening")

        vm.searchText = ""
        XCTAssertEqual(vm.filteredRides.count, 2)
    }

    func test_load_setsErrorOnFailure() async {
        let repo = MockRideRepository()
        repo.fetchError = MockError.intentional
        let vm = RideListViewModel(schoolId: "school_001", currentUserId: "me", rideRepo: repo)
        await vm.load()

        XCTAssertNotNil(vm.errorMessage)
        XCTAssertTrue(vm.rides.isEmpty)
    }

    func test_myRides_fetchesOwnDriverRides() async {
        let vm = RideListViewModel(schoolId: "school_001", currentUserId: "d1", rideRepo: seedRepo())
        await vm.load()

        XCTAssertEqual(vm.myRides.count, 1)
        XCTAssertEqual(vm.myRides.first?.id, "ride_morning")
    }
}
