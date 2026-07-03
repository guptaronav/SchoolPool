@preconcurrency import FirebaseFirestore

struct RideLocation: Codable, Sendable {
    let title: String
    let subtitle: String
    let latitude: Double
    let longitude: Double
}
