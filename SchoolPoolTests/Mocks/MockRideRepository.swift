import Foundation
import Combine
@testable import SchoolPool

final class MockRideRepository: RideRepositoryProtocol {
    var rides: [String: Ride] = [:]
    var createError: Error?
    var fetchError: Error?
    var updateError: Error?

    private(set) var createCallCount = 0
    private(set) var updateCallCount = 0

    private let subject = PassthroughSubject<Ride?, Never>()

    func create(_ ride: Ride) async throws {
        createCallCount += 1
        if let createError { throw createError }
        var stored = ride
        let id = ride.id ?? UUID().uuidString
        stored.id = id
        rides[id] = stored
    }

    func fetch(id: String) async throws -> Ride? {
        if let fetchError { throw fetchError }
        return rides[id]
    }

    func update(_ ride: Ride) async throws {
        updateCallCount += 1
        if let updateError { throw updateError }
        guard let id = ride.id else { return }
        rides[id] = ride
        subject.send(ride)
    }

    func fetchOpenRides(schoolId: String, after date: Date) async throws -> [Ride] {
        if let fetchError { throw fetchError }
        return rides.values
            .filter { $0.schoolId == schoolId && $0.status == .open && $0.departureTime.dateValue() > date }
            .sorted { $0.departureTime.dateValue() < $1.departureTime.dateValue() }
    }

    func fetchRides(driverId: String) async throws -> [Ride] {
        if let fetchError { throw fetchError }
        return rides.values
            .filter { $0.driverId == driverId }
            .sorted { $0.departureTime.dateValue() > $1.departureTime.dateValue() }
    }

    func fetchRides(passengerId: String) async throws -> [Ride] {
        if let fetchError { throw fetchError }
        return rides.values
            .filter { $0.hasPassenger(passengerId) }
            .sorted { $0.departureTime.dateValue() > $1.departureTime.dateValue() }
    }

    func observeRide(id: String) -> AnyPublisher<Ride?, Never> {
        subject.eraseToAnyPublisher()
    }

    private(set) var stopObservingCallCount = 0

    func stopObserving(id: String) {
        stopObservingCallCount += 1
    }
}
