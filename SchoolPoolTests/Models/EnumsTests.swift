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
}
