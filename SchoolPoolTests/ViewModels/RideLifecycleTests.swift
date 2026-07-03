import XCTest
@testable import SchoolPool

@MainActor
final class RideLifecycleTests: XCTestCase {

    private func makeDriverVM(
        ride: Ride = .stub()
    ) -> (vm: RideDetailViewModel, rides: MockRideRepository) {
        let rides = MockRideRepository()
        var seeded = ride
        seeded.id = seeded.id ?? "ride_001"
        rides.rides[seeded.id!] = seeded

        let booking = MockBookingService()
        booking.rideStore = rides

        let vm = RideDetailViewModel(
            rideId: seeded.id!,
            currentUserId: "driver_001",
            currentUserName: "Alex Johnson",
            rideRepo: rides,
            bookingService: booking
        )
        return (vm, rides)
    }

    func test_startRide_movesToInProgress() async {
        let (vm, rides) = makeDriverVM()
        await vm.load()
        await vm.startRide()

        XCTAssertEqual(vm.ride?.status, .inProgress)
        XCTAssertEqual(rides.rides["ride_001"]?.status, .inProgress)
    }

    func test_startRide_notAllowedWhenAlreadyFinished() async {
        let (vm, rides) = makeDriverVM(ride: .stub(status: .completed))
        await vm.load()
        await vm.startRide()

        XCTAssertEqual(rides.rides["ride_001"]?.status, .completed)
    }

    func test_completeRide_movesToCompleted() async {
        let (vm, rides) = makeDriverVM(ride: .stub(status: .inProgress))
        await vm.load()
        await vm.completeRide()

        XCTAssertEqual(vm.ride?.status, .completed)
        XCTAssertEqual(rides.rides["ride_001"]?.status, .completed)
    }

    func test_completeRide_requiresInProgress() async {
        let (vm, rides) = makeDriverVM(ride: .stub(status: .open))
        await vm.load()
        await vm.completeRide()

        XCTAssertEqual(rides.rides["ride_001"]?.status, .open)
    }

    func test_cancelRide_fromScheduled() async {
        let (vm, rides) = makeDriverVM()
        await vm.load()
        await vm.cancelRide()

        XCTAssertEqual(vm.ride?.status, .cancelled)
        XCTAssertEqual(rides.rides["ride_001"]?.status, .cancelled)
    }

    func test_cancelRide_notAllowedOnceInProgress() async {
        let (vm, rides) = makeDriverVM(ride: .stub(status: .inProgress))
        await vm.load()
        await vm.cancelRide()

        XCTAssertEqual(rides.rides["ride_001"]?.status, .inProgress)
    }
}
