import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var user: SPUser?
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let userRepo: UserRepositoryProtocol
    private let userId: String
    private var cancellables = Set<AnyCancellable>()

    init(userId: String, userRepo: UserRepositoryProtocol) {
        self.userId = userId
        self.userRepo = userRepo
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            user = try await userRepo.fetch(id: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func update(displayName: String) async {
        guard var u = user else { return }
        u.displayName = displayName
        do {
            try await userRepo.update(u)
            user = u
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
