import Foundation
@testable import SchoolPool

final class MockUserRepository: UserRepositoryProtocol {
    var users: [String: SPUser] = [:]
    var createError: Error?
    var fetchError: Error?
    var updateError: Error?

    private(set) var createCallCount = 0
    private(set) var updateCallCount = 0

    func create(_ user: SPUser) async throws {
        createCallCount += 1
        if let createError { throw createError }
        guard let id = user.id else { throw MockError.intentional }
        users[id] = user
    }

    func fetch(id: String) async throws -> SPUser? {
        if let fetchError { throw fetchError }
        return users[id]
    }

    func update(_ user: SPUser) async throws {
        updateCallCount += 1
        if let updateError { throw updateError }
        guard let id = user.id else { return }
        users[id] = user
    }

    func addNotificationToken(_ token: String, for userId: String) async throws {
        guard var u = users[userId] else { return }
        if !u.notificationTokens.contains(token) { u.notificationTokens.append(token) }
        users[userId] = u
    }

    func removeNotificationToken(_ token: String, for userId: String) async throws {
        guard var u = users[userId] else { return }
        u.notificationTokens.removeAll { $0 == token }
        users[userId] = u
    }
}
