import Foundation
import Combine
@preconcurrency import FirebaseFirestore

@MainActor
final class CreateRideViewModel: ObservableObject {
    @Published var origin: RideLocation?
    @Published var destination: RideLocation?
    @Published var departureDate = Date().addingTimeInterval(3600)
    @Published var seats = 3
    @Published var pricePerSeat: Double = 0
    @Published var notes = ""
    @Published private(set) var isSubmitting = false
    @Published private(set) var didSubmit = false
    @Published var errorMessage: String?

    static let seatRange = 1...7

    private let driverId: String
    private let driverName: String
    private let schoolId: String
    private let rideRepo: RideRepositoryProtocol

    init(driverId: String, driverName: String, schoolId: String, rideRepo: RideRepositoryProtocol) {
        self.driverId = driverId
        self.driverName = driverName
        self.schoolId = schoolId
        self.rideRepo = rideRepo
    }

    var canSubmit: Bool {
        origin != nil
            && destination != nil
            && departureDate > Date()
            && Self.seatRange.contains(seats)
    }

    func submit() async {
        guard canSubmit, let origin, let destination else { return }
        isSubmitting = true
        defer { isSubmitting = false }

        let ride = Ride(
            driverId: driverId,
            driverName: driverName,
            schoolId: schoolId,
            origin: origin,
            destination: destination,
            departureTime: Timestamp(date: departureDate),
            totalSeats: seats,
            seatsAvailable: seats,
            pricePerSeat: pricePerSeat,
            status: .open,
            passengerIds: [],
            notes: notes.isEmpty ? nil : notes,
            createdAt: Timestamp()
        )

        do {
            try await rideRepo.create(ride)
            didSubmit = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
