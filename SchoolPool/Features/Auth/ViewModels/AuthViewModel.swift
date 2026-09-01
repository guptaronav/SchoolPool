import Foundation
import Combine
@preconcurrency import FirebaseFirestore

@MainActor
final class AuthViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case signedIn(uid: String)
        case error(String)
    }

    @Published private(set) var state: State = .idle

    private let auth: AuthServiceProtocol
    private let userRepo: UserRepositoryProtocol

    init(auth: AuthServiceProtocol, userRepo: UserRepositoryProtocol) {
        self.auth = auth
        self.userRepo = userRepo
    }

    func signInWithGoogle() async {
        state = .loading
        do {
            let uid = try await auth.signInWithGoogle()
            try await ensureUserDoc(uid: uid)
            state = .signedIn(uid: uid)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    /// Debug-only mock login — no credentials, routes through the same
    /// user-doc bootstrap as any other new sign-in.
    func signInAnonymously() async {
        state = .loading
        do {
            let uid = try await auth.signInAnonymously()
            try await ensureUserDoc(uid: uid)
            state = .signedIn(uid: uid)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func signInWithEmail(_ email: String, password: String) async {
        state = .loading
        do {
            let uid = try await auth.signInWithEmail(email, password: password)
            state = .signedIn(uid: uid)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func signUp(email: String, password: String, displayName: String) async {
        state = .loading
        do {
            let uid = try await auth.signUp(email: email, password: password, displayName: displayName)
            try await ensureUserDoc(uid: uid, email: email, displayName: displayName)
            state = .signedIn(uid: uid)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func signOut() {
        do {
            try auth.signOut()
            state = .idle
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    /// Creates the user doc only when it's confirmed absent. A thrown fetch
    /// (network blip, permission hiccup) must propagate — treating it as
    /// "missing" would overwrite an existing profile with a blank one.
    private func ensureUserDoc(uid: String, email: String = "", displayName: String = "") async throws {
        if try await userRepo.fetch(id: uid) != nil { return }
        var newUser = SPUser(
            displayName: displayName.isEmpty ? "New User" : displayName,
            email: email,
            photoURL: nil,
            role: .student,
            verificationStatus: .unverified,
            schoolId: nil,
            linkedGuardianIds: [],
            linkedStudentIds: [],
            emergencyContactName: nil,
            emergencyContactPhone: nil,
            dropletsBalance: 0,
            poolLevel: .ripple,
            rideStreak: 0,
            createdAt: Timestamp(),
            lastActiveAt: Timestamp(),
            isEmailVerified: false,
            notificationTokens: [],
            privacySettings: PrivacySettings()
        )
        newUser.id = uid
        try await userRepo.create(newUser)
    }
}
