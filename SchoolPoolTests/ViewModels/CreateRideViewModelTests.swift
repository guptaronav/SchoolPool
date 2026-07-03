import XCTest
@testable import SchoolPool

@MainActor
final class CreateRideViewModelTests: XCTestCase {

    private func makeVM(repo: MockRideRepository = MockRideRepository()) -> CreateRideViewModel {
        CreateRideViewModel(
            driverId: "driver_001",
            driverName: "Alex Johnson",
            schoolId: "school_001",
            rideRepo: repo
        )
    }

    func test_initialState_isNotSubmittable() {
        let vm = makeVM()
        XCTAssertFalse(vm.canSubmit)
    }

    func test_canSubmit_whenAllFieldsValid() {
        let vm = makeVM()
        vm.origin = RideLocation(title: "123 Oak St", subtitle: "Stockton, CA", latitude: 37.9, longitude: -121.2)
        vm.destination = RideLocation(title: "Lincoln High", subtitle: "Stockton, CA", latitude: 37.95, longitude: -121.27)
        vm.departureDate = Date().addingTimeInterval(3600)
        vm.seats = 3
        XCTAssertTrue(vm.canSubmit)
    }

    func test_cannotSubmit_withPastDepartureDate() {
        let vm = makeVM()
        vm.origin = RideLocation(title: "A", subtitle: "", latitude: 0, longitude: 0)
        vm.destination = RideLocation(title: "B", subtitle: "", latitude: 1, longitude: 1)
        vm.departureDate = Date().addingTimeInterval(-3600)
        vm.seats = 3
        XCTAssertFalse(vm.canSubmit)
    }

    func test_submit_createsRideInRepository() async {
        let repo = MockRideRepository()
        let vm = makeVM(repo: repo)
        vm.origin = RideLocation(title: "123 Oak St", subtitle: "Stockton, CA", latitude: 37.9, longitude: -121.2)
        vm.destination = RideLocation(title: "Lincoln High", subtitle: "Stockton, CA", latitude: 37.95, longitude: -121.27)
        vm.departureDate = Date().addingTimeInterval(3600)
        vm.seats = 2
        vm.pricePerSeat = 5

        await vm.submit()

        XCTAssertEqual(repo.createCallCount, 1)
        XCTAssertTrue(vm.didSubmit)
        let created = repo.rides.values.first
        XCTAssertEqual(created?.driverId, "driver_001")
        XCTAssertEqual(created?.schoolId, "school_001")
        XCTAssertEqual(created?.totalSeats, 2)
        XCTAssertEqual(created?.seatsAvailable, 2)
        XCTAssertEqual(created?.pricePerSeat, 5)
        XCTAssertEqual(created?.status, .open)
    }

    func test_submit_setsErrorOnFailure() async {
        let repo = MockRideRepository()
        repo.createError = MockError.intentional
        let vm = makeVM(repo: repo)
        vm.origin = RideLocation(title: "A", subtitle: "", latitude: 0, longitude: 0)
        vm.destination = RideLocation(title: "B", subtitle: "", latitude: 1, longitude: 1)
        vm.departureDate = Date().addingTimeInterval(3600)

        await vm.submit()

        XCTAssertFalse(vm.didSubmit)
        XCTAssertNotNil(vm.errorMessage)
    }
}
