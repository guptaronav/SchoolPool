import SwiftUI

extension RideStatus {
    var displayName: String {
        switch self {
        case .open:       return "Open"
        case .full:       return "Full"
        case .inProgress: return "In Progress"
        case .completed:  return "Completed"
        case .cancelled:  return "Cancelled"
        }
    }

    var tint: Color {
        switch self {
        case .open:       return .spAccent
        case .full:       return .spDroplet
        case .inProgress: return .spPrimary
        case .completed:  return .spTextSecondary
        case .cancelled:  return .spDanger
        }
    }

    var iconName: String {
        switch self {
        case .open:       return "checkmark.circle.fill"
        case .full:       return "person.3.fill"
        case .inProgress: return "car.fill"
        case .completed:  return "flag.checkered"
        case .cancelled:  return "xmark.circle.fill"
        }
    }
}
