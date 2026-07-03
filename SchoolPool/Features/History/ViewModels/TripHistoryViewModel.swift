import Foundation

@MainActor
final class TripHistoryViewModel: ObservableObject {
    enum TripRole { case driver, passenger }

    @Published private(set) var trips: [Ride] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let currentUserId: String
    private let rideRepo: RideRepositoryProtocol

    init(currentUserId: String, rideRepo: RideRepositoryProtocol) {
        self.currentUserId = currentUserId
        self.rideRepo = rideRepo
    }

    func role(for ride: Ride) -> TripRole {
        ride.driverId == currentUserId ? .driver : .passenger
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let drivenTask = rideRepo.fetchRides(driverId: currentUserId)
            async let riddenTask = rideRepo.fetchRides(passengerId: currentUserId)
            let (driven, ridden) = try await (drivenTask, riddenTask)

            var byId: [String: Ride] = [:]
            for ride in driven + ridden where ride.status.isFinished {
                if let id = ride.id { byId[id] = ride }
            }
            trips = byId.values.sorted {
                $0.departureTime.dateValue() > $1.departureTime.dateValue()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
