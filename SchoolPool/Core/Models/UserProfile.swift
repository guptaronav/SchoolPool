@preconcurrency import FirebaseFirestore

struct UserProfile: Codable, Identifiable, Sendable {
    @DocumentID var id: String?
    var displayName: String
    var photoURL: String?
    var role: String
    var schoolId: String
    var poolLevel: String
    var ratingAverage: Double
    var ratingCount: Int
    var ridesCompleted: Int
}
