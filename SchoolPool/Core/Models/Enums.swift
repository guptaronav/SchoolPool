enum UserRole: String, Codable, CaseIterable, Sendable {
    case student, parent, teacher, community, schoolAdmin, superAdmin

    var displayName: String {
        switch self {
        case .student: return "Student"
        case .parent: return "Parent or Guardian"
        case .teacher: return "Teacher"
        case .community: return "Community Member"
        case .schoolAdmin: return "School Admin"
        case .superAdmin: return "Super Admin"
        }
    }

    var isSelectableDuringOnboarding: Bool {
        switch self {
        case .student, .parent, .teacher, .community: return true
        case .schoolAdmin, .superAdmin: return false
        }
    }
}

enum VerificationStatus: String, Codable, Sendable {
    case unverified, pending, verified, rejected, suspended
}

enum VerificationRequestStatus: String, Codable, Sendable {
    case pending, approved, rejected
}

enum PoolLevel: String, Codable, CaseIterable, Sendable {
    case ripple, stream, river, lake, ocean

    var minimumDroplets: Int {
        switch self {
        case .ripple: return 0
        case .stream: return 100
        case .river: return 500
        case .lake: return 1500
        case .ocean: return 5000
        }
    }

    static func forDroplets(_ count: Int) -> PoolLevel {
        PoolLevel.allCases.last(where: { count >= $0.minimumDroplets }) ?? .ripple
    }
}

enum RideStatus: String, Codable, CaseIterable, Sendable {
    case open, full, completed, cancelled
}

enum DayOfWeek: String, Codable, CaseIterable, Sendable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday

    var shortName: String {
        switch self {
        case .monday: return "M"
        case .tuesday: return "Tu"
        case .wednesday: return "W"
        case .thursday: return "Th"
        case .friday: return "F"
        case .saturday: return "Sa"
        case .sunday: return "Su"
        }
    }
}
