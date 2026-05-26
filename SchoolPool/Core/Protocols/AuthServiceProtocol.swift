import Foundation
import Combine

protocol AuthServiceProtocol {
    var currentUserId: String? { get }
    var currentUserPublisher: AnyPublisher<String?, Never> { get }

    func signInWithGoogle() async throws -> String
    func signInWithEmail(_ email: String, password: String) async throws -> String
    func signUp(email: String, password: String, displayName: String) async throws -> String
    func sendEmailVerification() async throws
    func reloadCurrentUser() async throws
    var isCurrentEmailVerified: Bool { get }
    func signOut() throws
    func deleteAccount() async throws
}
