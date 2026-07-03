import Foundation
@preconcurrency import FirebaseFirestore

/// Someone the current user can rate for a given completed ride.
struct RateableParticipant: Identifiable, Sendable {
    let id: String        // ratee user id
    let name: String
    let roleLabel: String // "Driver" or "Passenger"
}

@MainActor
final class RateRideViewModel: ObservableObject {
    @Published private(set) var participants: [RateableParticipant] = []
    @Published private(set) var ratedIds: Set<String> = []
    @Published private(set) var isLoading = false
    @Published private(set) var isSubmitting = false
    @Published var errorMessage: String?

    let ride: Ride
    private let currentUserId: String
    private let ratingService: RatingServiceProtocol
    private let bookingService: BookingServiceProtocol

    init(
        ride: Ride,
        currentUserId: String,
        ratingService: RatingServiceProtocol,
        bookingService: BookingServiceProtocol
    ) {
        self.ride = ride
        self.currentUserId = currentUserId
        self.ratingService = ratingService
        self.bookingService = bookingService
    }

    var isDriver: Bool { ride.driverId == currentUserId }

    var canRate: Bool { ride.status == .completed }

    func load() async {
        guard canRate, let rideId = ride.id else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            if isDriver {
                // Driver rates each accepted passenger.
                let requests = try await bookingService.fetchRequests(forRide: rideId)
                participants = requests
                    .filter { $0.status == .accepted }
                    .map { RateableParticipant(id: $0.riderId, name: $0.riderName, roleLabel: "Passenger") }
            } else if ride.hasPassenger(currentUserId) {
                // Passenger rates the driver.
                participants = [RateableParticipant(id: ride.driverId, name: ride.driverName, roleLabel: "Driver")]
            } else {
                participants = []
            }

            for participant in participants {
                if try await ratingService.hasRated(rideId: rideId, raterId: currentUserId, rateeId: participant.id) {
                    ratedIds.insert(participant.id)
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func submit(rateeId: String, stars: Int, comment: String) async {
        guard let rideId = ride.id, (1...5).contains(stars) else {
            errorMessage = RatingError.invalidStars.localizedDescription
            return
        }
        isSubmitting = true
        defer { isSubmitting = false }

        let rating = Rating(
            rideId: rideId,
            raterId: currentUserId,
            rateeId: rateeId,
            stars: stars,
            comment: comment.isEmpty ? nil : comment,
            createdAt: Timestamp()
        )
        do {
            try await ratingService.submit(rating)
            ratedIds.insert(rateeId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func hasRated(_ rateeId: String) -> Bool { ratedIds.contains(rateeId) }
}
