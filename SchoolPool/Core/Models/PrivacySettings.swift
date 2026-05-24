import Foundation

struct PrivacySettings: Codable, Equatable {
    var hidePhone: Bool
    var hideAddress: Bool
    var locationSharingConsent: Bool

    init(hidePhone: Bool = true,
         hideAddress: Bool = true,
         locationSharingConsent: Bool = false) {
        self.hidePhone = hidePhone
        self.hideAddress = hideAddress
        self.locationSharingConsent = locationSharingConsent
    }
}
