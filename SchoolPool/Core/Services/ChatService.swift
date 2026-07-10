import Foundation
import Combine
@preconcurrency import FirebaseFirestore

final class ChatService: ChatServiceProtocol {
    private let db = Firestore.firestore()
    private var listeners: [String: ListenerRegistration] = [:]

    private func messages(for rideId: String) -> CollectionReference {
        db.collection("rides").document(rideId).collection("messages")
    }

    func send(_ message: ChatMessage) async throws {
        try messages(for: message.rideId).document().setData(from: message)
    }

    func observeMessages(rideId: String) -> AnyPublisher<[ChatMessage], Never> {
        let subject = CurrentValueSubject<[ChatMessage], Never>([])
        listeners[rideId]?.remove()
        listeners[rideId] = messages(for: rideId)
            .order(by: "sentAt", descending: false)
            .addSnapshotListener { snap, _ in
                let items = snap?.documents.compactMap { try? $0.data(as: ChatMessage.self) } ?? []
                subject.send(items)
            }
        return subject.eraseToAnyPublisher()
    }

    func stopObserving(rideId: String) {
        listeners.removeValue(forKey: rideId)?.remove()
    }

    deinit { listeners.values.forEach { $0.remove() } }
}
