import Foundation
@preconcurrency import FirebaseFirestore

enum RatingError: LocalizedError {
    case invalidStars
    case alreadyRated

    var errorDescription: String? {
        switch self {
        case .invalidStars: return "Please choose between 1 and 5 stars."
        case .alreadyRated: return "You've already rated this person for this ride."
        }
    }
}

final class RatingService: RatingServiceProtocol {
    private let db = Firestore.firestore()
    private var ratings: CollectionReference { db.collection("ratings") }

    func submit(_ rating: Rating) async throws {
        guard rating.isValid else { throw RatingError.invalidStars }
        let alreadyRated = try await hasRated(
            rideId: rating.rideId,
            raterId: rating.raterId,
            rateeId: rating.rateeId
        )
        guard !alreadyRated else { throw RatingError.alreadyRated }
        try ratings.document().setData(from: rating)
    }

    func hasRated(rideId: String, raterId: String, rateeId: String) async throws -> Bool {
        let snap = try await ratings
            .whereField("rideId", isEqualTo: rideId)
            .whereField("raterId", isEqualTo: raterId)
            .whereField("rateeId", isEqualTo: rateeId)
            .limit(to: 1)
            .getDocuments()
        return !snap.documents.isEmpty
    }

    func fetchRatings(forUser rateeId: String) async throws -> [Rating] {
        let snap = try await ratings
            .whereField("rateeId", isEqualTo: rateeId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snap.documents.compactMap { try? $0.data(as: Rating.self) }
    }

    func averageStars(forUser rateeId: String) async throws -> Double? {
        let all = try await fetchRatings(forUser: rateeId)
        guard !all.isEmpty else { return nil }
        let total = all.reduce(0) { $0 + $1.stars }
        return Double(total) / Double(all.count)
    }
}
