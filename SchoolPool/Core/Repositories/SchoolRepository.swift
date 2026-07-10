import Foundation
@preconcurrency import FirebaseFirestore

final class SchoolRepository: SchoolRepositoryProtocol {
    private let db = Firestore.firestore()

    func search(query: String, limit: Int = 20) async throws -> [School] {
        let q = query.lowercased()
        let snap = try await db.collection("schools")
            .whereField("nameLowercase", isGreaterThanOrEqualTo: q)
            .whereField("nameLowercase", isLessThan: q + "\u{f8ff}")
            .whereField("isOnboarded", isEqualTo: true)
            .limit(to: limit)
            .getDocuments()
        return snap.documents.compactMap { try? $0.data(as: School.self) }
    }

    func fetch(id: String) async throws -> School? {
        let snap = try await db.collection("schools").document(id).getDocument()
        return try? snap.data(as: School.self)
    }
}
