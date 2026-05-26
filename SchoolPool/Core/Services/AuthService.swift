import UIKit
import Foundation
import Combine
import GoogleSignIn
@preconcurrency import FirebaseAuth

@MainActor
final class AuthService: NSObject, AuthServiceProtocol {

    static let shared = AuthService()

    private let subject = CurrentValueSubject<String?, Never>(Auth.auth().currentUser?.uid)
    private var authStateListener: AuthStateDidChangeListenerHandle?

    override init() {
        super.init()
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.subject.send(user?.uid)
        }
    }

    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }

    var currentUserId: String? { Auth.auth().currentUser?.uid }
    var currentUserPublisher: AnyPublisher<String?, Never> { subject.eraseToAnyPublisher() }
    var isCurrentEmailVerified: Bool { Auth.auth().currentUser?.isEmailVerified ?? false }

    // MARK: - Google Sign-In

    func signInWithGoogle() async throws -> String {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let root = windowScene.keyWindow?.rootViewController else {
            throw AuthError.noRootViewController
        }

        // Walk to the topmost presented VC — required when SignInView is open as a sheet
        var presenter = root
        while let presented = presenter.presentedViewController {
            presenter = presented
        }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenter)
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.missingIDToken
        }
        let accessToken = result.user.accessToken.tokenString
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        let authResult = try await Auth.auth().signIn(with: credential)
        return authResult.user.uid
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

    func signOut() throws {
        GIDSignIn.sharedInstance.signOut()
        try Auth.auth().signOut()
    }

    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { throw AuthError.notSignedIn }
        try await user.delete()
    }
}

// MARK: - AuthError

enum AuthError: Error {
    case notSignedIn
    case missingClientID
    case missingIDToken
    case noRootViewController
}
