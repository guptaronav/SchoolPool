import XCTest
@testable import SchoolPool

@MainActor
final class RideDetailViewModelTests: XCTestCase {

    private func makeContext(
        ride: Ride = .stub(),
        userId: String = "rider_001"
    ) -> (vm: RideDetailViewModel, rides: MockRideRepository, booking: MockBookingService) {
        let rides = MockRideRepository()
        var seeded = ride
        seeded.id = seeded.id ?? "ride_001"
        rides.rides[seeded.id!] = seeded

        let booking = MockBookingService()
        booking.rideStore = rides

        let vm = RideDetailViewModel(
            rideId: seeded.id!,
            currentUserId: userId,
            currentUserName: "Jordan Smith",
            rideRepo: rides,
            bookingService: booking
        )
        return (vm, rides, booking)
    }

    func test_load_populatesRide() async {
        let (vm, _, _) = makeContext()
        await vm.load()
        XCTAssertNotNil(vm.ride)
        XCTAssertEqual(vm.ride?.driverId, "driver_001")
    }

    func test_riderRole_canRequestSeat() async {
        let (vm, _, _) = makeContext()
        await vm.load()
        XCTAssertFalse(vm.isDriver)
        XCTAssertTrue(vm.canRequestSeat)
    }

    func test_driverRole_cannotRequestSeat() async {
        let (vm, _, _) = makeContext(userId: "driver_001")
        await vm.load()
        XCTAssertTrue(vm.isDriver)
        XCTAssertFalse(vm.canRequestSeat)
    }

    func test_requestSeat_createsPendingRequest() async {
        let (vm, _, booking) = makeContext()
        await vm.load()
        await vm.requestSeat()

        XCTAssertEqual(booking.requestSeatCallCount, 1)
        XCTAssertEqual(vm.myRequest?.status, .pending)
        XCTAssertFalse(vm.canRequestSeat)
    }

    func test_requestSeat_onFullRide_setsError() async {
        let (vm, _, _) = makeContext(ride: .stub(totalSeats: 1, seatsAvailable: 0))
        await vm.load()
        await vm.requestSeat()
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertNil(vm.myRequest)
    }

    func test_cancelRequest_revertsToRequestable() async {
        let (vm, _, _) = makeContext()
        await vm.load()
        await vm.requestSeat()
        await vm.cancelRequest()

        XCTAssertEqual(vm.myRequest?.status, .cancelled)
        XCTAssertTrue(vm.canRequestSeat)
    }

    func test_driver_seesPendingRequests() async {
        let (vm, _, booking) = makeContext(userId: "driver_001")
        var request = RideRequest.stub()
        request.id = "req_1"
        booking.requests["req_1"] = request

        await vm.load()
        XCTAssertEqual(vm.pendingRequests.count, 1)
    }

    func test_driver_accept_updatesRideSeats() async {
        let (vm, rides, booking) = makeContext(userId: "driver_001")
        var request = RideRequest.stub()
        request.id = "req_1"
        booking.requests["req_1"] = request

        await vm.load()
        await vm.accept(request)

        XCTAssertEqual(booking.acceptCallCount, 1)
        XCTAssertEqual(rides.rides["ride_001"]?.seatsAvailable, 2)
        XCTAssertEqual(rides.rides["ride_001"]?.passengerIds, ["rider_001"])
        XCTAssertTrue(vm.pendingRequests.isEmpty)
    }

    func test_driver_decline_removesFromPending() async {
        let (vm, _, booking) = makeContext(userId: "driver_001")
        var request = RideRequest.stub()
        request.id = "req_1"
        booking.requests["req_1"] = request

        await vm.load()
        await vm.decline(request)

        XCTAssertEqual(booking.declineCallCount, 1)
        XCTAssertTrue(vm.pendingRequests.isEmpty)
    }
}
