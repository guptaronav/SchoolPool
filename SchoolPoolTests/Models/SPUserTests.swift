import XCTest
import FirebaseFirestore
@testable import SchoolPool

final class SPUserTests: XCTestCase {

    func test_stub_hasConservativePrivacyDefaults() {
        let u = SPUser.stub()
        XCTAssertTrue(u.privacySettings.hidePhone)
        XCTAssertTrue(u.privacySettings.hideAddress)
        XCTAssertFalse(u.privacySettings.locationSharingConsent)
    }

    func test_isFullyVerified_trueOnlyForVerifiedStatus() {
        XCTAssertTrue(SPUser.stub(verificationStatus: .verified).isFullyVerified)
        for status in [VerificationStatus.unverified, .pending, .rejected, .suspended] {
            XCTAssertFalse(SPUser.stub(verificationStatus: status).isFullyVerified)
        }
    }

    func test_canDrive_falseForAdmins() {
        XCTAssertFalse(SPUser.stub(role: .schoolAdmin, verificationStatus: .verified).canDrive)
        XCTAssertFalse(SPUser.stub(role: .superAdmin, verificationStatus: .verified).canDrive)
    }

    func test_canDrive_requiresVerified() {
        XCTAssertFalse(SPUser.stub(role: .parent, verificationStatus: .pending).canDrive)
        XCTAssertTrue(SPUser.stub(role: .parent, verificationStatus: .verified).canDrive)
    }
}
