import Foundation
@preconcurrency import FirebaseFirestore
@preconcurrency import FirebaseStorage

final class VerificationService: VerificationServiceProtocol {
    private let db = Firestore.firestore()
    private let storage = Storage.storage().reference()

    func submit(request: VerificationRequest, documents: [Data]) async throws {
        var req = request

        var paths: [String] = []
        for (i, data) in documents.enumerated() {
            let path = "verifications/\(req.userId)/\(UUID().uuidString)-\(i).jpg"
            let ref = storage.child(path)
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            _ = try await ref.putDataAsync(data, metadata: metadata)
            paths.append(path)
        }
        req.documentStoragePaths = paths

        let docRef = db.collection("verificationRequests").document()
        try await docRef.setData(from: req)

        try await db.collection("users").document(req.userId).updateData([
            "verificationStatus": VerificationStatus.pending.rawValue
        ])
    }

    func fetchPending(forSchoolId: String) async throws -> [VerificationRequest] {
        let snap = try await db.collection("verificationRequests")
            .whereField("schoolId", isEqualTo: forSchoolId)
            .whereField("status", isEqualTo: VerificationRequestStatus.pending.rawValue)
            .order(by: "submittedAt", descending: false)
            .getDocuments()
        return snap.documents.compactMap { try? $0.data(as: VerificationRequest.self) }
    }

    func approve(requestId: String, adminNote: String?) async throws {
        try await db.collection("verificationRequests").document(requestId).updateData([
            "status": VerificationRequestStatus.approved.rawValue,
            "reviewNote": (adminNote ?? "") as String,
            "reviewedAt": Timestamp()
        ])
    }

    func reject(requestId: String, reason: String) async throws {
        try await db.collection("verificationRequests").document(requestId).updateData([
            "status": VerificationRequestStatus.rejected.rawValue,
            "reviewNote": reason,
            "reviewedAt": Timestamp()
        ])
    }

    func fetchLatestRequest(forUserId: String) async throws -> VerificationRequest? {
        let snap = try await db.collection("verificationRequests")
            .whereField("userId", isEqualTo: forUserId)
            .order(by: "submittedAt", descending: true)
            .limit(to: 1)
            .getDocuments()
        return snap.documents.first.flatMap { try? $0.data(as: VerificationRequest.self) }
    }
}
