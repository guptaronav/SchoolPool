import SwiftUI
import Combine

struct RootView: View {
    @StateObject private var authVM: AuthViewModel
    @State private var currentUser: SPUser?
    @State private var isLoadingUser = true
    @State private var authState: AuthState = .loading

    private let userRepo: UserRepositoryProtocol
    private let schoolRepo: SchoolRepositoryProtocol
    private let verificationService: VerificationServiceProtocol

    init() {
        let auth = AuthService.shared
        let userRepo = UserRepository()
        let schoolRepo = SchoolRepository()
        let verificationService = VerificationService()
        _authVM = StateObject(wrappedValue: AuthViewModel(auth: auth, userRepo: userRepo))
        self.userRepo = userRepo
        self.schoolRepo = schoolRepo
        self.verificationService = verificationService
    }

    var body: some View {
        Group {
            switch routingState {
            case .loading:
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.spBackground)

            case .unauthenticated:
                WelcomeView(vm: authVM)

            case .needsOnboarding(let uid):
                NavigationStack {
                    OnboardingFlowView(
                        uid: uid,
                        userRepo: userRepo,
                        schoolRepo: schoolRepo,
                        verificationService: verificationService,
                        authService: AuthService.shared
                    )
                }

            case .pending:
                NavigationStack {
                    PendingApprovalView(
                        vm: makeOnboardingVM(uid: currentUser?.id ?? ""),
                        onSignOut: { try? AuthService.shared.signOut() }
                    )
                }

            case .suspended:
                SuspendedView()

            case .verified(let uid):
                MainTabView(
                    userId: uid,
                    userRepo: userRepo,
                    onSignOut: { try? AuthService.shared.signOut() }
                )
            }
        }
        .task { await observeAuth() }
    }

    private enum RoutingState {
        case loading
        case unauthenticated
        case needsOnboarding(uid: String)
        case pending
        case suspended
        case verified(uid: String)
    }

    private enum AuthState { case loading, known }

    private var routingState: RoutingState {
        if case .loading = authState { return .loading }
        guard let uid = AuthService.shared.currentUserId else { return .unauthenticated }
        guard let user = currentUser else {
            return isLoadingUser ? .loading : .needsOnboarding(uid: uid)
        }
        switch user.verificationStatus {
        case .unverified:  return .needsOnboarding(uid: uid)
        case .pending:     return .pending
        case .verified:    return .verified(uid: uid)
        case .rejected:    return .needsOnboarding(uid: uid)
        case .suspended:   return .suspended
        }
    }

    private func observeAuth() async {
        for await uid in AuthService.shared.currentUserPublisher.values {
            authState = .known
            if let uid {
                isLoadingUser = true
                currentUser = try? await userRepo.fetch(id: uid)
                isLoadingUser = false
            } else {
                currentUser = nil
                isLoadingUser = false
            }
        }
    }

    private func makeOnboardingVM(uid: String) -> OnboardingViewModel {
        OnboardingViewModel(
            auth: AuthService.shared,
            userRepo: userRepo,
            schoolRepo: schoolRepo,
            verificationService: verificationService
        )
    }
}
