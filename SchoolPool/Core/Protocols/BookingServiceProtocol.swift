import Foundation

protocol BookingServiceProtocol {
    func requestSeat(ride: Ride, riderId: String, riderName: String) async throws
    func cancelRequest(_ requestId: String) async throws
    func accept(_ request: RideRequest) async throws
    func decline(_ request: RideRequest) async throws
    func fetchRequests(forRide rideId: String) async throws -> [RideRequest]
    func fetchRequests(forRider riderId: String) async throws -> [RideRequest]
}
