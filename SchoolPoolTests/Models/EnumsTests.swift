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
        XCTAssertEqual(RideStatus.allCases.count, 5)
        let statuses: [RideStatus] = [.open, .full, .inProgress, .completed, .cancelled]
        XCTAssertEqual(RideStatus.allCases.sorted(by: { $0.rawValue < $1.rawValue }), statuses.sorted(by: { $0.rawValue < $1.rawValue }))
    }

    func test_dayOfWeek_allCases() {
        XCTAssertEqual(DayOfWeek.allCases.count, 7)
        let days: [DayOfWeek] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        XCTAssertEqual(DayOfWeek.allCases.count, days.count)
    }

    func test_dayOfWeek_shortNames() {
        XCTAssertEqual(DayOfWeek.monday.shortName, "M")
        XCTAssertEqual(DayOfWeek.tuesday.shortName, "Tu")
        XCTAssertEqual(DayOfWeek.wednesday.shortName, "W")
        XCTAssertEqual(DayOfWeek.thursday.shortName, "Th")
        XCTAssertEqual(DayOfWeek.friday.shortName, "F")
        XCTAssertEqual(DayOfWeek.saturday.shortName, "Sa")
        XCTAssertEqual(DayOfWeek.sunday.shortName, "Su")
    }

    func test_dayOfWeek_shortNames_areUnique() {
        let shortNames = DayOfWeek.allCases.map(\.shortName)
        XCTAssertEqual(shortNames.count, Set(shortNames).count, "Day abbreviations must be unique")
    }
}
