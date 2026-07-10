import Foundation
import Combine

protocol RideRepositoryProtocol {
    func create(_ ride: Ride) async throws
    func fetch(id: String) async throws -> Ride?
    func update(_ ride: Ride) async throws
    func fetchOpenRides(schoolId: String, after date: Date) async throws -> [Ride]
    func fetchRides(driverId: String) async throws -> [Ride]
    func fetchRides(passengerId: String) async throws -> [Ride]
    func observeRide(id: String) -> AnyPublisher<Ride?, Never>
    func stopObserving(id: String)
}
