import Foundation

extension PoolLevel {
    var displayName: String {
        switch self {
        case .ripple: return "Ripple"
        case .stream: return "Stream"
        case .river:  return "River"
        case .lake:   return "Lake"
        case .ocean:  return "Ocean"
        }
    }
}
