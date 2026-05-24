import SwiftUI

struct PendingApprovalView: View {
    @ObservedObject var vm: OnboardingViewModel
    let onSignOut: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "clock.fill")
                .font(.system(size: 72))
                .foregroundStyle(Color.spAccent)

            VStack(spacing: 12) {
                Text("Request submitted!")
                    .font(.title.bold())
                Text("A school admin is reviewing your verification request. You'll be notified when it's approved — this usually takes 1–2 business days.")
                    .font(.subheadline)
                    .foregroundStyle(Color.spTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Spacer()
        }
        .background(Color.spBackground.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Sign Out", role: .destructive) { onSignOut() }
                    .foregroundStyle(Color.spDanger)
            }
        }
    }
}
