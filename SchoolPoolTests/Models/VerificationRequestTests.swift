import XCTest
@testable import SchoolPool

final class VerificationRequestTests: XCTestCase {
    func test_stub_defaultStatus_isPending() {
        let req = VerificationRequest.stub()
        XCTAssertEqual(req.status, .pending)
    }

    func test_stub_customStatus() {
        let req = VerificationRequest.stub(status: .approved)
        XCTAssertEqual(req.status, .approved)
    }

    func test_stub_hasDocumentImages() {
        let req = VerificationRequest.stub()
        XCTAssertFalse(req.documentImages.isEmpty)
    }
}
