import SwiftUI

struct EmailVerificationPendingView: View {
    @ObservedObject var vm: OnboardingViewModel
    @State private var pollTimer: Timer?

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "envelope.badge.fill")
                .font(.system(size: 72))
                .foregroundStyle(Color.spPrimary)

            VStack(spacing: 12) {
                Text("Check your school email")
                    .font(.title.bold())
                Text("We sent a verification link to your school email address. Click the link to verify, then tap the button below.")
                    .font(.subheadline)
                    .foregroundStyle(Color.spTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            VStack(spacing: 12) {
                SPButton(title: "I've verified my email") {
                    Task { await vm.checkEmailVerification() }
                }

                Button("Resend verification email") {
                    Task { await vm.sendVerificationEmail() }
                }
                .font(.subheadline)
                .foregroundStyle(Color.spPrimary)
            }
            .padding(.horizontal, 24)

            if let err = vm.errorMessage {
                Text(err).font(.caption).foregroundStyle(Color.spDanger)
            }

            Spacer()
        }
        .background(Color.spBackground.ignoresSafeArea())
        .onAppear { startPolling() }
        .onDisappear { pollTimer?.invalidate() }
    }

    private func startPolling() {
        pollTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            Task { await vm.checkEmailVerification() }
        }
    }
}
