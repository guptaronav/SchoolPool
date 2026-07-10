import Foundation
@preconcurrency import FirebaseFirestore

final class UserRepository: UserRepositoryProtocol {
    private let db = Firestore.firestore()

    func create(_ user: SPUser) async throws {
        guard let id = user.id else {
            throw NSError(domain: "UserRepository", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "User must have id"])
        }
        try db.collection("users").document(id).setData(from: user)
    }

    func fetch(id: String) async throws -> SPUser? {
        let snap = try await db.collection("users").document(id).getDocument()
        guard snap.exists else { return nil }
        return try snap.data(as: SPUser.self)
    }

    func update(_ user: SPUser) async throws {
        guard let id = user.id else { return }
        try db.collection("users").document(id).setData(from: user, merge: true)
    }

    func addNotificationToken(_ token: String, for userId: String) async throws {
        try await db.collection("users").document(userId).updateData([
            "notificationTokens": FieldValue.arrayUnion([token])
        ])
    }

    func removeNotificationToken(_ token: String, for userId: String) async throws {
        try await db.collection("users").document(userId).updateData([
            "notificationTokens": FieldValue.arrayRemove([token])
        ])
    }
}
