import Foundation
import Combine
@preconcurrency import FirebaseFirestore

final class UserRepository: UserRepositoryProtocol {
    private let db = Firestore.firestore()
    private var listeners: [String: ListenerRegistration] = [:]

    func create(_ user: SPUser) async throws {
        guard let id = user.id else {
            throw NSError(domain: "UserRepository", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "User must have id"])
        }
        try db.collection("users").document(id).setData(from: user)
    }

    func fetch(id: String) async throws -> SPUser? {
        let snap = try await db.collection("users").document(id).getDocument()
        return try? snap.data(as: SPUser.self)
    }

    func update(_ user: SPUser) async throws {
        guard let id = user.id else { return }
        try db.collection("users").document(id).setData(from: user, merge: true)
    }

    func updateVerificationStatus(_ status: VerificationStatus, for userId: String) async throws {
        try await db.collection("users").document(userId).updateData([
            "verificationStatus": status.rawValue
        ])
    }

    func observeUser(id: String) -> AnyPublisher<SPUser?, Never> {
        let subject = PassthroughSubject<SPUser?, Never>()
        listeners[id]?.remove()
        listeners[id] = db.collection("users").document(id).addSnapshotListener { snap, _ in
            subject.send(try? snap?.data(as: SPUser.self))
        }
        return subject.eraseToAnyPublisher()
    }

    deinit { listeners.values.forEach { $0.remove() } }
}
