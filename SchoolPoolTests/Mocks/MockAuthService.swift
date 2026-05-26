import Foundation
import Combine
@testable import SchoolPool

final class MockAuthService: AuthServiceProtocol {
    var stubbedUid: String = "user_001"
    var shouldThrowOnSignIn: Bool = false
    var shouldThrowOnSignUp: Bool = false
    var isEmailVerified: Bool = false

    private let subject = CurrentValueSubject<String?, Never>(nil)

    var currentUserId: String? { shouldThrowOnSignIn ? nil : stubbedUid }
    var currentUserPublisher: AnyPublisher<String?, Never> { subject.eraseToAnyPublisher() }
    var isCurrentEmailVerified: Bool { isEmailVerified }

    private(set) var signInWithGoogleCallCount = 0
    private(set) var signInWithEmailCallCount = 0
    private(set) var signUpCallCount = 0
    private(set) var signOutCallCount = 0
    private(set) var sendEmailVerificationCallCount = 0
    private(set) var reloadCurrentUserCallCount = 0

    func signInWithGoogle() async throws -> String {
        signInWithGoogleCallCount += 1
        if shouldThrowOnSignIn { throw MockError.intentional }
        subject.send(stubbedUid)
        return stubbedUid
    }

    func signInWithEmail(_ email: String, password: String) async throws -> String {
        signInWithEmailCallCount += 1
        if shouldThrowOnSignIn { throw MockError.intentional }
        subject.send(stubbedUid)
        return stubbedUid
    }

    func signUp(email: String, password: String, displayName: String) async throws -> String {
        signUpCallCount += 1
        if shouldThrowOnSignUp { throw MockError.intentional }
        subject.send(stubbedUid)
        return stubbedUid
    }

    func sendEmailVerification() async throws {
        sendEmailVerificationCallCount += 1
    }

    func reloadCurrentUser() async throws {
        reloadCurrentUserCallCount += 1
    }

    func signOut() throws {
        signOutCallCount += 1
        subject.send(nil)
    }

    func deleteAccount() async throws {}
}

enum MockError: Error {
    case intentional
}
