import Foundation
import Combine

protocol ChatServiceProtocol {
    func send(_ message: ChatMessage) async throws
    func observeMessages(rideId: String) -> AnyPublisher<[ChatMessage], Never>
    func fetchMessages(rideId: String) async throws -> [ChatMessage]
}
