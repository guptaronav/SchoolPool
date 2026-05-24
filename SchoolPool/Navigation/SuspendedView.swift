import SwiftUI

struct SuspendedView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.spDanger)

            Text("Account Suspended")
                .font(.title.bold())

            Text("Your account is currently suspended. Contact support@schoolpool.app to appeal.")
                .font(.subheadline)
                .foregroundStyle(Color.spTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Link("Email Support", destination: URL(string: "mailto:support@schoolpool.app")!)
                .foregroundStyle(Color.spPrimary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.spBackground.ignoresSafeArea())
    }
}
