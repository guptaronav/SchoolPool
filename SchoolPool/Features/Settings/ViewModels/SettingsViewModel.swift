import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var hidePhone = true
    @Published var hideAddress = true
    @Published var locationSharingConsent = false
    @Published private(set) var isWorking = false
    @Published var errorMessage: String?

    private let userId: String
    private let userRepo: UserRepositoryProtocol
    private let authService: AuthServiceProtocol
    private var user: SPUser?

    init(userId: String, userRepo: UserRepositoryProtocol, authService: AuthServiceProtocol) {
        self.userId = userId
        self.userRepo = userRepo
        self.authService = authService
    }

    func load() async {
        do {
            guard let fetched = try await userRepo.fetch(id: userId) else { return }
            user = fetched
            hidePhone = fetched.privacySettings.hidePhone
            hideAddress = fetched.privacySettings.hideAddress
            locationSharingConsent = fetched.privacySettings.locationSharingConsent
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func savePrivacy() async {
        guard var current = user else { return }
        isWorking = true
        defer { isWorking = false }
        current.privacySettings = PrivacySettings(
            hidePhone: hidePhone,
            hideAddress: hideAddress,
            locationSharingConsent: locationSharingConsent
        )
        do {
            try await userRepo.update(current)
            user = current
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteAccount() async {
        isWorking = true
        defer { isWorking = false }
        do {
            try await authService.deleteAccount()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
