@preconcurrency import FirebaseFirestore

struct School: Codable, Identifiable, Sendable {
    @DocumentID var id: String?
    var name: String
    var district: String?
    var city: String
    var state: String
    var country: String
    var emailDomains: [String]
    var adminUserIds: [String]
    var isOnboarded: Bool
    var isPending: Bool
    var createdAt: Timestamp
    var studentCount: Int

    func matches(emailDomain candidate: String) -> Bool {
        let lc = candidate.lowercased()
        return emailDomains.contains { $0.lowercased() == lc }
    }
}

#if DEBUG
extension School {
    static func stub(
        name: String = "Lincoln High School",
        emailDomains: [String] = ["lincoln.edu"],
        isOnboarded: Bool = true,
        adminUserIds: [String] = ["admin_001"]
    ) -> School {
        School(
            name: name,
            district: "Lincoln Unified",
            city: "Stockton",
            state: "CA",
            country: "US",
            emailDomains: emailDomains,
            adminUserIds: adminUserIds,
            isOnboarded: isOnboarded,
            isPending: !isOnboarded,
            createdAt: Timestamp(),
            studentCount: 1200
        )
    }
}
#endif
