import Foundation
import Combine

protocol UserRepositoryProtocol {
    func create(_ user: SPUser) async throws
    func fetch(id: String) async throws -> SPUser?
    func update(_ user: SPUser) async throws
    func updateVerificationStatus(_ status: VerificationStatus, for userId: String) async throws
    func addNotificationToken(_ token: String, for userId: String) async throws
    func removeNotificationToken(_ token: String, for userId: String) async throws
    func observeUser(id: String) -> AnyPublisher<SPUser?, Never>
}
