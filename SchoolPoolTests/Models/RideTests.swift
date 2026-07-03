import XCTest
@testable import SchoolPool
@preconcurrency import FirebaseFirestore

final class RideTests: XCTestCase {

    func test_stub_hasOpenStatusAndSeats() {
        let ride = Ride.stub()
        XCTAssertEqual(ride.status, .open)
        XCTAssertEqual(ride.totalSeats, 3)
        XCTAssertEqual(ride.seatsAvailable, 3)
        XCTAssertFalse(ride.isFull)
    }

    func test_isFull_whenNoSeatsAvailable() {
        let ride = Ride.stub(totalSeats: 2, seatsAvailable: 0)
        XCTAssertTrue(ride.isFull)
    }

    func test_hasPassenger_detectsMembership() {
        let ride = Ride.stub(passengerIds: ["user_A", "user_B"])
        XCTAssertTrue(ride.hasPassenger("user_A"))
        XCTAssertFalse(ride.hasPassenger("user_C"))
    }

    func test_firestoreEncoding_mapsExpectedFields() throws {
        let ride = Ride.stub(pricePerSeat: 5, passengerIds: ["user_A"])
        let fields = try Firestore.Encoder().encode(ride)

        XCTAssertEqual(fields["driverId"] as? String, "driver_001")
        XCTAssertEqual(fields["schoolId"] as? String, "school_001")
        XCTAssertEqual(fields["status"] as? String, RideStatus.open.rawValue)
        XCTAssertEqual(fields["totalSeats"] as? Int, 3)
        XCTAssertEqual(fields["pricePerSeat"] as? Double, 5)
        XCTAssertEqual(fields["passengerIds"] as? [String], ["user_A"])
        let origin = fields["origin"] as? [String: Any]
        XCTAssertEqual(origin?["title"] as? String, ride.origin.title)
    }

    // Note: decoding a `@DocumentID` model is only supported from a real
    // DocumentSnapshot, so full decode is exercised via integration, not here.
    // The encoding test above validates the CodingKeys / field mapping.
}
