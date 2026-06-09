import XCTest
@testable import SchoolPool

final class RideLocationTests: XCTestCase {

    func test_rideLocation_decodable() {
        let json = """
        {
            "title": "123 Oak Street",
            "subtitle": "Springfield, CA",
            "latitude": 38.2975,
            "longitude": -122.2869
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let location = try? decoder.decode(RideLocation.self, from: json)
        XCTAssertNotNil(location)
        XCTAssertEqual(location?.title, "123 Oak Street")
    }

    func test_rideLocation_encodable() {
        let location = RideLocation(
            title: "Lincoln High",
            subtitle: "Stockton, CA",
            latitude: 37.9577,
            longitude: -121.2723
        )
        let encoder = JSONEncoder()
        let data = try? encoder.encode(location)
        XCTAssertNotNil(data)
    }
}
