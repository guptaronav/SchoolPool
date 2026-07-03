@preconcurrency import FirebaseFirestore

struct Ride: Codable, Identifiable, Sendable {
    @DocumentID var id: String?
    var driverId: String
    var driverName: String
    var schoolId: String
    var origin: RideLocation
    var destination: RideLocation
    var departureTime: Timestamp
    var totalSeats: Int
    var seatsAvailable: Int
    var pricePerSeat: Double
    var status: RideStatus
    var passengerIds: [String]
    var notes: String?
    var createdAt: Timestamp

    var isFull: Bool { seatsAvailable <= 0 }

    func hasPassenger(_ userId: String) -> Bool {
        passengerIds.contains(userId)
    }
}

#if DEBUG
extension Ride {
    static func stub(
        driverId: String = "driver_001",
        driverName: String = "Alex Johnson",
        schoolId: String = "school_001",
        totalSeats: Int = 3,
        seatsAvailable: Int = 3,
        pricePerSeat: Double = 0,
        status: RideStatus = .open,
        passengerIds: [String] = [],
        departureTime: Timestamp = Timestamp(date: Date().addingTimeInterval(3600))
    ) -> Ride {
        Ride(
            driverId: driverId,
            driverName: driverName,
            schoolId: schoolId,
            origin: RideLocation(title: "123 Oak Street", subtitle: "Stockton, CA", latitude: 37.9577, longitude: -121.2908),
            destination: RideLocation(title: "Lincoln High School", subtitle: "Stockton, CA", latitude: 37.9747, longitude: -121.3103),
            departureTime: departureTime,
            totalSeats: totalSeats,
            seatsAvailable: seatsAvailable,
            pricePerSeat: pricePerSeat,
            status: status,
            passengerIds: passengerIds,
            notes: nil,
            createdAt: Timestamp()
        )
    }
}
#endif
