import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @ObservedObject var vm: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "car.2.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.spPrimary)
                        Text("Welcome back")
                            .font(.title2.bold())
                        Text("Sign in to your SchoolPool account")
                            .font(.subheadline)
                            .foregroundStyle(Color.spTextSecondary)
                    }
                    .padding(.top, 32)

                    // Email + password fields
                    VStack(spacing: 16) {
                        SPTextField(title: "Email", text: $email, keyboard: .emailAddress)
                        SPTextField(title: "Password", text: $password, isSecure: true)
                    }

                    // Error state
                    if case .error(let msg) = vm.state {
                        Text(msg)
                            .font(.caption)
                            .foregroundStyle(Color.spDanger)
                            .multilineTextAlignment(.center)
                    }

                    // Sign in button
                    SPButton(
                        title: "Sign In",
                        isLoading: vm.state == .loading
                    ) {
                        Task { await vm.signInWithEmail(email, password: password) }
                    }

                    // Divider
                    HStack {
                        Rectangle().frame(height: 1).foregroundStyle(Color.spTextSecondary.opacity(0.2))
                        Text("or").font(.caption).foregroundStyle(Color.spTextSecondary)
                        Rectangle().frame(height: 1).foregroundStyle(Color.spTextSecondary.opacity(0.2))
                    }

                    // Sign in with Apple
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { _ in
                        Task { await vm.signInWithApple() }
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .background(Color.spBackground.ignoresSafeArea())
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .onChange(of: vm.state) { _, newState in
            if case .signedIn = newState { dismiss() }
        }
    }
}
