import Foundation
import Combine
@preconcurrency import FirebaseFirestore

final class RideRepository: RideRepositoryProtocol {
    private let db = Firestore.firestore()
    private var listeners: [String: ListenerRegistration] = [:]

    private var rides: CollectionReference { db.collection("rides") }

    func create(_ ride: Ride) async throws {
        try rides.document().setData(from: ride)
    }

    func fetch(id: String) async throws -> Ride? {
        let snap = try await rides.document(id).getDocument()
        return try? snap.data(as: Ride.self)
    }

    func update(_ ride: Ride) async throws {
        guard let id = ride.id else {
            throw NSError(domain: "RideRepository", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Ride must have id"])
        }
        try rides.document(id).setData(from: ride, merge: true)
    }

    func fetchOpenRides(schoolId: String, after date: Date) async throws -> [Ride] {
        let snap = try await rides
            .whereField("schoolId", isEqualTo: schoolId)
            .whereField("status", isEqualTo: RideStatus.open.rawValue)
            .whereField("departureTime", isGreaterThan: Timestamp(date: date))
            .order(by: "departureTime", descending: false)
            .getDocuments()
        return snap.documents.compactMap { try? $0.data(as: Ride.self) }
    }

    func fetchRides(driverId: String) async throws -> [Ride] {
        let snap = try await rides
            .whereField("driverId", isEqualTo: driverId)
            .order(by: "departureTime", descending: true)
            .getDocuments()
        return snap.documents.compactMap { try? $0.data(as: Ride.self) }
    }

    func fetchRides(passengerId: String) async throws -> [Ride] {
        let snap = try await rides
            .whereField("passengerIds", arrayContains: passengerId)
            .order(by: "departureTime", descending: true)
            .getDocuments()
        return snap.documents.compactMap { try? $0.data(as: Ride.self) }
    }

    func observeRide(id: String) -> AnyPublisher<Ride?, Never> {
        let subject = PassthroughSubject<Ride?, Never>()
        listeners[id]?.remove()
        listeners[id] = rides.document(id).addSnapshotListener { snap, _ in
            subject.send(try? snap?.data(as: Ride.self))
        }
        return subject.eraseToAnyPublisher()
    }

    func stopObserving(id: String) {
        listeners.removeValue(forKey: id)?.remove()
    }

    deinit { listeners.values.forEach { $0.remove() } }
}
