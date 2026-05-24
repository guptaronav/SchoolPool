import Foundation
import Combine

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

    func signInWithApple() async {
        state = .loading
        do {
            let uid = try await auth.signInWithApple()
            await ensureUserDoc(uid: uid)
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
            await ensureUserDoc(uid: uid, email: email, displayName: displayName)
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

    private func ensureUserDoc(uid: String, email: String = "", displayName: String = "") async {
        if let existing = try? await userRepo.fetch(id: uid), existing != nil { return }
        var newUser = SPUser.stub(
            displayName: displayName.isEmpty ? "New User" : displayName,
            email: email,
            role: .student,
            verificationStatus: .unverified
        )
        newUser.id = uid
        try? await userRepo.create(newUser)
    }
}
