import Foundation
import Combine
@testable import SchoolPool
@preconcurrency import FirebaseFirestore

final class MockChatService: ChatServiceProtocol {
    var messagesStore: [String: [ChatMessage]] = [:]
    var sendError: Error?

    private(set) var sendCallCount = 0
    private let subject = CurrentValueSubject<[ChatMessage], Never>([])

    func send(_ message: ChatMessage) async throws {
        sendCallCount += 1
        if let sendError { throw sendError }
        var stored = message
        stored.id = UUID().uuidString
        messagesStore[message.rideId, default: []].append(stored)
        subject.send(messagesStore[message.rideId] ?? [])
    }

    func observeMessages(rideId: String) -> AnyPublisher<[ChatMessage], Never> {
        subject.send(messagesStore[rideId] ?? [])
        return subject.eraseToAnyPublisher()
    }

    private(set) var stopObservingCallCount = 0

    func stopObserving(rideId: String) {
        stopObservingCallCount += 1
    }
}
