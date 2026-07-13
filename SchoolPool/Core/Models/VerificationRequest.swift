@preconcurrency import FirebaseFirestore

struct VerificationRequest: Codable, Identifiable, Sendable {
    @DocumentID var id: String?
    var userId: String
    var schoolId: String?
    var schoolNameFreeText: String?
    var studentIdNumberHash: String
    var documentImages: [Data]
    var status: VerificationRequestStatus
    var reviewedByAdminId: String?
    var reviewNote: String?
    var submittedAt: Timestamp
    var reviewedAt: Timestamp?
}

#if DEBUG
extension VerificationRequest {
    static func stub(
        userId: String = "user_001",
        schoolId: String? = "school_001",
        status: VerificationRequestStatus = .pending
    ) -> VerificationRequest {
        VerificationRequest(
            userId: userId,
            schoolId: schoolId,
            schoolNameFreeText: nil,
            studentIdNumberHash: "abc123hash",
            documentImages: [Data([0xFF, 0xD8, 0xFF])],
            status: status,
            reviewedByAdminId: nil,
            reviewNote: nil,
            submittedAt: Timestamp(),
            reviewedAt: nil
        )
    }
}
#endif
