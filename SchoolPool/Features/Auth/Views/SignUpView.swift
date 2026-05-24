import SwiftUI
import AuthenticationServices

struct SignUpView: View {
    @ObservedObject var vm: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var validationError: String?

    private var isFormValid: Bool {
        !displayName.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") && email.contains(".") &&
        password.count >= 8
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.spPrimary)
                        Text("Create account")
                            .font(.title2.bold())
                        Text("Join your school community")
                            .font(.subheadline)
                            .foregroundStyle(Color.spTextSecondary)
                    }
                    .padding(.top, 32)

                    // Fields
                    VStack(spacing: 16) {
                        SPTextField(title: "Display Name", text: $displayName,
                                    autocapitalization: .words)
                        SPTextField(title: "Email", text: $email,
                                    keyboard: .emailAddress)
                        SPTextField(title: "Password (min 8 characters)", text: $password,
                                    isSecure: true)
                    }

                    // Validation / error
                    if let err = validationError {
                        Text(err).font(.caption).foregroundStyle(Color.spDanger)
                    } else if case .error(let msg) = vm.state {
                        Text(msg).font(.caption).foregroundStyle(Color.spDanger)
                    }

                    // Sign up button
                    SPButton(title: "Create Account", isLoading: vm.state == .loading) {
                        guard isFormValid else {
                            validationError = password.count < 8
                                ? "Password must be at least 8 characters"
                                : "Please enter a valid email address"
                            return
                        }
                        validationError = nil
                        Task { await vm.signUp(email: email, password: password, displayName: displayName) }
                    }

                    // Divider
                    HStack {
                        Rectangle().frame(height: 1).foregroundStyle(Color.spTextSecondary.opacity(0.2))
                        Text("or").font(.caption).foregroundStyle(Color.spTextSecondary)
                        Rectangle().frame(height: 1).foregroundStyle(Color.spTextSecondary.opacity(0.2))
                    }

                    // SIWA
                    SignInWithAppleButton(.signUp) { request in
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
