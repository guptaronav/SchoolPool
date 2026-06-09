import XCTest
@testable import SchoolPool

final class EnumsTests: XCTestCase {

    func test_userRole_onboardingSelectable() {
        XCTAssertTrue(UserRole.student.isSelectableDuringOnboarding)
        XCTAssertTrue(UserRole.parent.isSelectableDuringOnboarding)
        XCTAssertTrue(UserRole.teacher.isSelectableDuringOnboarding)
        XCTAssertTrue(UserRole.community.isSelectableDuringOnboarding)
        XCTAssertFalse(UserRole.schoolAdmin.isSelectableDuringOnboarding)
        XCTAssertFalse(UserRole.superAdmin.isSelectableDuringOnboarding)
    }

    func test_poolLevel_thresholdsAreMonotonic() {
        let droplets = PoolLevel.allCases.map(\.minimumDroplets)
        XCTAssertEqual(droplets, droplets.sorted(), "Pool level thresholds must increase")
        XCTAssertEqual(PoolLevel.ripple.minimumDroplets, 0)
    }

    func test_poolLevel_forDroplets_picksHighestEligible() {
        XCTAssertEqual(PoolLevel.forDroplets(0), .ripple)
        XCTAssertEqual(PoolLevel.forDroplets(99), .ripple)
        XCTAssertEqual(PoolLevel.forDroplets(100), .stream)
        XCTAssertEqual(PoolLevel.forDroplets(1500), .lake)
        XCTAssertEqual(PoolLevel.forDroplets(99_999), .ocean)
    }

    func test_privacySettings_defaultsAreConservative() {
        let p = PrivacySettings()
        XCTAssertTrue(p.hidePhone)
        XCTAssertTrue(p.hideAddress)
        XCTAssertFalse(p.locationSharingConsent)
    }

    func test_rideStatus_allCases() {
        XCTAssertEqual(RideStatus.allCases.count, 4)
        let statuses: [RideStatus] = [.open, .full, .completed, .cancelled]
        XCTAssertEqual(RideStatus.allCases.sorted(by: { $0.rawValue < $1.rawValue }), statuses.sorted(by: { $0.rawValue < $1.rawValue }))
    }

    func test_dayOfWeek_allCases() {
        XCTAssertEqual(DayOfWeek.allCases.count, 7)
        let days: [DayOfWeek] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        XCTAssertEqual(DayOfWeek.allCases.count, days.count)
    }

    func test_dayOfWeek_shortNames() {
        XCTAssertEqual(DayOfWeek.monday.shortName, "M")
        XCTAssertEqual(DayOfWeek.tuesday.shortName, "T")
        XCTAssertEqual(DayOfWeek.wednesday.shortName, "W")
        XCTAssertEqual(DayOfWeek.thursday.shortName, "T")
        XCTAssertEqual(DayOfWeek.friday.shortName, "F")
        XCTAssertEqual(DayOfWeek.saturday.shortName, "S")
        XCTAssertEqual(DayOfWeek.sunday.shortName, "S")
    }
}
