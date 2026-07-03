import XCTest
@testable import SchoolPool

@MainActor
final class RateRideViewModelTests: XCTestCase {

    private func makeContext(
        ride: Ride,
        userId: String
    ) -> (vm: RateRideViewModel, rating: MockRatingService, booking: MockBookingService) {
        let rating = MockRatingService()
        let booking = MockBookingService()
        let vm = RateRideViewModel(
            ride: ride,
            currentUserId: userId,
            ratingService: rating,
            bookingService: booking
        )
        return (vm, rating, booking)
    }

    func test_canRate_onlyWhenCompleted() {
        let openRide = Ride.stub(status: .open)
        let (openVM, _, _) = makeContext(ride: openRide, userId: "driver_001")
        XCTAssertFalse(openVM.canRate)

        var completed = Ride.stub(status: .completed)
        completed.id = "ride_001"
        let (doneVM, _, _) = makeContext(ride: completed, userId: "driver_001")
        XCTAssertTrue(doneVM.canRate)
    }

    func test_passenger_ratesDriver() async {
        var ride = Ride.stub(status: .completed, passengerIds: ["rider_001"])
        ride.id = "ride_001"
        let (vm, _, _) = makeContext(ride: ride, userId: "rider_001")
        await vm.load()

        XCTAssertEqual(vm.participants.count, 1)
        XCTAssertEqual(vm.participants.first?.id, "driver_001")
        XCTAssertEqual(vm.participants.first?.roleLabel, "Driver")
    }

    func test_driver_ratesAcceptedPassengers() async {
        var ride = Ride.stub(status: .completed, passengerIds: ["rider_001"])
        ride.id = "ride_001"
        let (vm, _, booking) = makeContext(ride: ride, userId: "driver_001")
        var accepted = RideRequest.stub(riderId: "rider_001", status: .accepted)
        accepted.id = "req_1"
        booking.requests["req_1"] = accepted
        var declined = RideRequest.stub(riderId: "rider_002", status: .declined)
        declined.id = "req_2"
        booking.requests["req_2"] = declined

        await vm.load()

        XCTAssertEqual(vm.participants.count, 1)
        XCTAssertEqual(vm.participants.first?.id, "rider_001")
        XCTAssertEqual(vm.participants.first?.roleLabel, "Passenger")
    }

    func test_submit_recordsRatingAndMarksRated() async {
        var ride = Ride.stub(status: .completed, passengerIds: ["rider_001"])
        ride.id = "ride_001"
        let (vm, rating, _) = makeContext(ride: ride, userId: "rider_001")
        await vm.load()
        await vm.submit(rateeId: "driver_001", stars: 5, comment: "Smooth")

        XCTAssertEqual(rating.submitCallCount, 1)
        XCTAssertTrue(vm.hasRated("driver_001"))
        XCTAssertEqual(rating.ratings.first?.stars, 5)
        XCTAssertEqual(rating.ratings.first?.comment, "Smooth")
    }

    func test_submit_rejectsInvalidStars() async {
        var ride = Ride.stub(status: .completed, passengerIds: ["rider_001"])
        ride.id = "ride_001"
        let (vm, rating, _) = makeContext(ride: ride, userId: "rider_001")
        await vm.submit(rateeId: "driver_001", stars: 0, comment: "")

        XCTAssertEqual(rating.submitCallCount, 0)
        XCTAssertNotNil(vm.errorMessage)
    }

    func test_load_marksAlreadyRatedParticipants() async {
        var ride = Ride.stub(status: .completed, passengerIds: ["rider_001"])
        ride.id = "ride_001"
        let (vm, rating, _) = makeContext(ride: ride, userId: "rider_001")
        rating.ratings.append(.stub(rideId: "ride_001", raterId: "rider_001", rateeId: "driver_001"))

        await vm.load()
        XCTAssertTrue(vm.hasRated("driver_001"))
    }
}
