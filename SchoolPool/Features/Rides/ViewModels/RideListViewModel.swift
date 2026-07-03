import Foundation
import Combine

@MainActor
final class RideListViewModel: ObservableObject {
    @Published private(set) var rides: [Ride] = []
    @Published private(set) var myRides: [Ride] = []
    @Published private(set) var isLoading = false
    @Published var searchText = ""
    @Published var errorMessage: String?

    private let schoolId: String
    private let currentUserId: String
    private let rideRepo: RideRepositoryProtocol

    init(schoolId: String, currentUserId: String, rideRepo: RideRepositoryProtocol) {
        self.schoolId = schoolId
        self.currentUserId = currentUserId
        self.rideRepo = rideRepo
    }

    var filteredRides: [Ride] {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        guard !query.isEmpty else { return rides }
        return rides.filter { ride in
            ride.origin.title.lowercased().contains(query)
                || ride.destination.title.lowercased().contains(query)
                || ride.driverName.lowercased().contains(query)
        }
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let open = try await rideRepo.fetchOpenRides(schoolId: schoolId, after: Date())
            rides = open.filter { $0.driverId != currentUserId }
            myRides = try await rideRepo.fetchRides(driverId: currentUserId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
