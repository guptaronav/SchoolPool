import Foundation
@testable import SchoolPool
@preconcurrency import FirebaseFirestore

final class MockBookingService: BookingServiceProtocol {
    var requests: [String: RideRequest] = [:]
    var rideStore: MockRideRepository?
    var requestError: Error?
    var respondError: Error?

    private(set) var requestSeatCallCount = 0
    private(set) var acceptCallCount = 0
    private(set) var declineCallCount = 0

    func requestSeat(ride: Ride, riderId: String, riderName: String) async throws {
        requestSeatCallCount += 1
        if let requestError { throw requestError }
        guard let rideId = ride.id else { throw BookingError.missingId }
        guard !ride.isFull else { throw BookingError.rideFull }
        let dup = requests.values.contains {
            $0.rideId == rideId && $0.riderId == riderId
                && ($0.status == .pending || $0.status == .accepted)
        }
        guard !dup else { throw BookingError.alreadyRequested }

        var request = RideRequest.stub(
            rideId: rideId, riderId: riderId, riderName: riderName,
            driverId: ride.driverId, schoolId: ride.schoolId
        )
        let id = UUID().uuidString
        request.id = id
        requests[id] = request
    }

    func cancelRequest(_ requestId: String) async throws {
        guard var request = requests[requestId] else { throw BookingError.missingId }
        request.status = .cancelled
        request.respondedAt = Timestamp()
        requests[requestId] = request
    }

    func accept(_ request: RideRequest) async throws {
        acceptCallCount += 1
        if let respondError { throw respondError }
        guard let id = request.id else { throw BookingError.missingId }
        guard var ride = rideStore?.rides[request.rideId], !ride.isFull else {
            throw BookingError.rideFull
        }
        ride.seatsAvailable -= 1
        ride.passengerIds.append(request.riderId)
        if ride.isFull { ride.status = .full }
        rideStore?.rides[request.rideId] = ride

        var updated = request
        updated.status = .accepted
        updated.respondedAt = Timestamp()
        requests[id] = updated
    }

    func decline(_ request: RideRequest) async throws {
        declineCallCount += 1
        if let respondError { throw respondError }
        guard let id = request.id else { throw BookingError.missingId }
        var updated = request
        updated.status = .declined
        updated.respondedAt = Timestamp()
        requests[id] = updated
    }

    func fetchRequests(forRide rideId: String) async throws -> [RideRequest] {
        if let requestError { throw requestError }
        return requests.values
            .filter { $0.rideId == rideId }
            .sorted { $0.createdAt.dateValue() < $1.createdAt.dateValue() }
    }

    func fetchRequests(forRider riderId: String) async throws -> [RideRequest] {
        if let requestError { throw requestError }
        return requests.values
            .filter { $0.riderId == riderId }
            .sorted { $0.createdAt.dateValue() > $1.createdAt.dateValue() }
    }
}
