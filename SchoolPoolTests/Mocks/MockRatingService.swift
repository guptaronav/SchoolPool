import Foundation
@testable import SchoolPool

final class MockRatingService: RatingServiceProtocol {
    var ratings: [Rating] = []
    var submitError: Error?

    private(set) var submitCallCount = 0

    func submit(_ rating: Rating) async throws {
        submitCallCount += 1
        if let submitError { throw submitError }
        guard rating.isValid else { throw RatingError.invalidStars }
        let dup = ratings.contains {
            $0.rideId == rating.rideId && $0.raterId == rating.raterId && $0.rateeId == rating.rateeId
        }
        guard !dup else { throw RatingError.alreadyRated }
        ratings.append(rating)
    }

    func hasRated(rideId: String, raterId: String, rateeId: String) async throws -> Bool {
        ratings.contains {
            $0.rideId == rideId && $0.raterId == raterId && $0.rateeId == rateeId
        }
    }
}
