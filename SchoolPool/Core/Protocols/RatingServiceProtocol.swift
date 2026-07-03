import Foundation

protocol RatingServiceProtocol {
    func submit(_ rating: Rating) async throws
    func hasRated(rideId: String, raterId: String, rateeId: String) async throws -> Bool
    func fetchRatings(forUser rateeId: String) async throws -> [Rating]
    func averageStars(forUser rateeId: String) async throws -> Double?
}
