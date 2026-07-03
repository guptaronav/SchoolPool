@preconcurrency import FirebaseFirestore

enum RideRequestStatus: String, Codable, Sendable {
    case pending, accepted, declined, cancelled
}

struct RideRequest: Codable, Identifiable, Sendable {
    @DocumentID var id: String?
    var rideId: String
    var riderId: String
    var riderName: String
    var driverId: String
    var schoolId: String
    var status: RideRequestStatus
    var createdAt: Timestamp
    var respondedAt: Timestamp?

    var isPending: Bool { status == .pending }
}

#if DEBUG
extension RideRequest {
    static func stub(
        rideId: String = "ride_001",
        riderId: String = "rider_001",
        riderName: String = "Jordan Smith",
        driverId: String = "driver_001",
        schoolId: String = "school_001",
        status: RideRequestStatus = .pending
    ) -> RideRequest {
        RideRequest(
            rideId: rideId,
            riderId: riderId,
            riderName: riderName,
            driverId: driverId,
            schoolId: schoolId,
            status: status,
            createdAt: Timestamp(),
            respondedAt: nil
        )
    }
}
#endif
