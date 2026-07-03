@preconcurrency import FirebaseFirestore

struct Rating: Codable, Identifiable, Sendable {
    @DocumentID var id: String?
    var rideId: String
    var raterId: String
    var rateeId: String
    var stars: Int
    var comment: String?
    var createdAt: Timestamp

    var isValid: Bool { (1...5).contains(stars) }
}

#if DEBUG
extension Rating {
    static func stub(
        rideId: String = "ride_001",
        raterId: String = "rater_001",
        rateeId: String = "ratee_001",
        stars: Int = 5,
        comment: String? = "Great ride!"
    ) -> Rating {
        Rating(
            rideId: rideId,
            raterId: raterId,
            rateeId: rateeId,
            stars: stars,
            comment: comment,
            createdAt: Timestamp()
        )
    }
}
#endif
