import SwiftUI

// Wraps the OnboardingViewModel and routes between onboarding steps
struct OnboardingFlowView: View {
    @StateObject private var vm: OnboardingViewModel

    init(uid: String, userRepo: UserRepositoryProtocol,
         schoolRepo: SchoolRepositoryProtocol,
         verificationService: VerificationServiceProtocol,
         authService: AuthServiceProtocol) {
        _vm = StateObject(wrappedValue: OnboardingViewModel(
            auth: authService,
            userRepo: userRepo,
            schoolRepo: schoolRepo,
            verificationService: verificationService
        ))
    }

    var body: some View {
        Group {
            switch vm.step {
            case .role:
                RoleSelectionView(vm: vm)
            case .school:
                SchoolSearchView(vm: vm, userEmail: "")
            case .emailWaiting:
                EmailVerificationPendingView(vm: vm)
            case .documentUpload:
                DocumentUploadView(vm: vm)
            case .pendingReview:
                PendingApprovalView(vm: vm, onSignOut: { try? AuthService.shared.signOut() })
            case .complete:
                // RootView will pick up the state change via observeAuth
                ProgressView("Finalizing...")
            }
        }
        .animation(.easeInOut, value: vm.step)
    }
}
