import UIKit
import Foundation
import Combine
import AuthenticationServices
import CryptoKit
@preconcurrency import FirebaseAuth

@MainActor
final class AuthService: NSObject, AuthServiceProtocol {

    static let shared = AuthService()

    nonisolated(unsafe) private let subject = CurrentValueSubject<String?, Never>(Auth.auth().currentUser?.uid)
    nonisolated(unsafe) private var currentNonce: String?
    nonisolated(unsafe) private var siwaContinuation: CheckedContinuation<String, Error>?
    private var authStateListener: AuthStateDidChangeListenerHandle?

    override init() {
        super.init()
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.subject.send(user?.uid)
        }
    }

    nonisolated var currentUserId: String? { Auth.auth().currentUser?.uid }
    nonisolated var currentUserPublisher: AnyPublisher<String?, Never> { subject.eraseToAnyPublisher() }
    nonisolated var isCurrentEmailVerified: Bool { Auth.auth().currentUser?.isEmailVerified ?? false }

    // MARK: - Sign in with Apple

    func signInWithApple() async throws -> String {
        let nonce = Self.randomNonceString()
        currentNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = Self.sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self

        return try await withCheckedThrowingContinuation { continuation in
            self.siwaContinuation = continuation
            controller.performRequests()
        }
    }

    // MARK: - Email / Password

    func signInWithEmail(_ email: String, password: String) async throws -> String {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user.uid
    }

    func signUp(email: String, password: String, displayName: String) async throws -> String {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let change = result.user.createProfileChangeRequest()
        change.displayName = displayName
        try await change.commitChanges()
        try await result.user.sendEmailVerification()
        return result.user.uid
    }

    func sendEmailVerification() async throws {
        guard let user = Auth.auth().currentUser else { throw AuthError.notSignedIn }
        try await user.sendEmailVerification()
    }

    func reloadCurrentUser() async throws {
        try await Auth.auth().currentUser?.reload()
    }

    nonisolated func signOut() throws {
        try Auth.auth().signOut()
    }

    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { throw AuthError.notSignedIn }
        try await user.delete()
    }

    // MARK: - Nonce helpers

    private static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remaining = length
        while remaining > 0 {
            var random: UInt8 = 0
            _ = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if random < charset.count {
                result.append(charset[Int(random)])
                remaining -= 1
            }
        }
        return result
    }

    private static func sha256(_ input: String) -> String {
        let hashed = SHA256.hash(data: Data(input.utf8))
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - AuthError

enum AuthError: Error {
    case notSignedIn
    case missingIdentityToken
    case invalidAppleCredential
}

// MARK: - ASAuthorizationControllerDelegate

extension AuthService: ASAuthorizationControllerDelegate {
    nonisolated func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce,
              let tokenData = credential.identityToken,
              let idToken = String(data: tokenData, encoding: .utf8) else {
            Task { @MainActor in
                self.siwaContinuation?.resume(throwing: AuthError.invalidAppleCredential)
                self.siwaContinuation = nil
            }
            return
        }

        let firebaseCredential = OAuthProvider.credential(
            providerID: AuthProviderID.apple,
            idToken: idToken,
            rawNonce: nonce
        )

        Task { @MainActor in
            do {
                let result = try await Auth.auth().signIn(with: firebaseCredential)
                if let givenName = credential.fullName?.givenName,
                   let familyName = credential.fullName?.familyName,
                   result.additionalUserInfo?.isNewUser == true {
                    let change = result.user.createProfileChangeRequest()
                    change.displayName = "\(givenName) \(familyName)"
                    try? await change.commitChanges()
                }
                self.siwaContinuation?.resume(returning: result.user.uid)
            } catch {
                self.siwaContinuation?.resume(throwing: error)
            }
            self.siwaContinuation = nil
        }
    }

    nonisolated func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        Task { @MainActor in
            self.siwaContinuation?.resume(throwing: error)
            self.siwaContinuation = nil
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AuthService: ASAuthorizationControllerPresentationContextProviding {
    nonisolated func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        MainActor.assumeIsolated {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow } ?? ASPresentationAnchor()
        }
    }
}
