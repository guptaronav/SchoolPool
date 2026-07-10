import Foundation

protocol RatingServiceProtocol {
    func submit(_ rating: Rating) async throws
    func hasRated(rideId: String, raterId: String, rateeId: String) async throws -> Bool
}
