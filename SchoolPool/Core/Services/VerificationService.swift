import Foundation
@preconcurrency import FirebaseFirestore
@preconcurrency import FirebaseStorage

enum VerificationError: LocalizedError {
    case missingId
    case missingSchool

    var errorDescription: String? {
        switch self {
        case .missingId: return "This request can't be processed right now."
        case .missingSchool: return "This request isn't linked to a school."
        }
    }
}

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

        // Claim the school on the user doc first: the request-create rule checks
        // the claimed school matches, and storage admin reads key off it.
        var userFields: [String: Any] = [
            "verificationStatus": VerificationStatus.pending.rawValue
        ]
        if let schoolId = req.schoolId {
            userFields["schoolId"] = schoolId
        }
        try await db.collection("users").document(req.userId).updateData(userFields)

        let docRef = db.collection("verificationRequests").document()
        try docRef.setData(from: req)
    }

    func fetchPending(forSchoolId: String) async throws -> [VerificationRequest] {
        let snap = try await db.collection("verificationRequests")
            .whereField("schoolId", isEqualTo: forSchoolId)
            .whereField("status", isEqualTo: VerificationRequestStatus.pending.rawValue)
            .order(by: "submittedAt", descending: false)
            .getDocuments()
        return snap.documents.compactMap { try? $0.data(as: VerificationRequest.self) }
    }

    /// Approval must also flip the applicant's user doc, or they stay routed to
    /// the pending screen forever. Batched so both writes land atomically.
    func approve(request: VerificationRequest, adminNote: String?) async throws {
        guard let requestId = request.id else { throw VerificationError.missingId }
        guard let schoolId = request.schoolId else { throw VerificationError.missingSchool }

        let batch = db.batch()
        batch.updateData([
            "status": VerificationRequestStatus.approved.rawValue,
            "reviewNote": (adminNote ?? "") as String,
            "reviewedAt": Timestamp()
        ], forDocument: db.collection("verificationRequests").document(requestId))
        batch.updateData([
            "verificationStatus": VerificationStatus.verified.rawValue,
            "schoolId": schoolId
        ], forDocument: db.collection("users").document(request.userId))
        try await batch.commit()
    }

    func reject(request: VerificationRequest, reason: String) async throws {
        guard let requestId = request.id else { throw VerificationError.missingId }

        let batch = db.batch()
        batch.updateData([
            "status": VerificationRequestStatus.rejected.rawValue,
            "reviewNote": reason,
            "reviewedAt": Timestamp()
        ], forDocument: db.collection("verificationRequests").document(requestId))
        // Send the applicant back to onboarding instead of leaving them stuck on "pending".
        var userFields: [String: Any] = [
            "verificationStatus": VerificationStatus.rejected.rawValue
        ]
        if let schoolId = request.schoolId {
            userFields["schoolId"] = schoolId
        }
        batch.updateData(userFields, forDocument: db.collection("users").document(request.userId))
        try await batch.commit()
    }
}
