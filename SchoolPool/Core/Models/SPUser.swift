@preconcurrency import FirebaseFirestore

struct SPUser: Codable, Identifiable, Sendable {
    @DocumentID var id: String?
    var displayName: String
    var email: String
    var photoURL: String?
    var role: UserRole
    var verificationStatus: VerificationStatus
    var schoolId: String?
    var linkedGuardianIds: [String]
    var linkedStudentIds: [String]
    var emergencyContactName: String?
    var emergencyContactPhone: String?
    var dropletsBalance: Int
    var poolLevel: PoolLevel
    var rideStreak: Int
    var createdAt: Timestamp
    var lastActiveAt: Timestamp
    var isEmailVerified: Bool
    var notificationTokens: [String]
    var privacySettings: PrivacySettings

    var isFullyVerified: Bool { verificationStatus == .verified }

    var canDrive: Bool {
        guard isFullyVerified else { return false }
        switch role {
        case .student, .parent, .teacher, .community: return true
        case .schoolAdmin, .superAdmin: return false
        }
    }
}

#if DEBUG
extension SPUser {
    static func stub(
        displayName: String = "Alex Johnson",
        email: String = "alex@lincoln.edu",
        role: UserRole = .student,
        verificationStatus: VerificationStatus = .verified,
        schoolId: String? = "school_001",
        dropletsBalance: Int = 0
    ) -> SPUser {
        SPUser(
            displayName: displayName,
            email: email,
            photoURL: nil,
            role: role,
            verificationStatus: verificationStatus,
            schoolId: schoolId,
            linkedGuardianIds: [],
            linkedStudentIds: [],
            emergencyContactName: nil,
            emergencyContactPhone: nil,
            dropletsBalance: dropletsBalance,
            poolLevel: PoolLevel.forDroplets(dropletsBalance),
            rideStreak: 0,
            createdAt: Timestamp(),
            lastActiveAt: Timestamp(),
            isEmailVerified: true,
            notificationTokens: [],
            privacySettings: PrivacySettings()
        )
    }
}
#endif
