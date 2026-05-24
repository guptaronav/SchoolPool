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

    func test_stub_hasDocumentPaths() {
        let req = VerificationRequest.stub(userId: "u42")
        XCTAssertFalse(req.documentStoragePaths.isEmpty)
        XCTAssertTrue(req.documentStoragePaths[0].contains("u42"))
    }
}
