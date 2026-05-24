import XCTest
@testable import SchoolPool

final class KeychainTests: XCTestCase {
    override func setUp() {
        super.setUp()
        Keychain.delete(.firebaseToken)
        Keychain.delete(.userId)
    }

    func test_saveAndLoad_roundTrip() {
        XCTAssertTrue(Keychain.save("token-abc", for: .firebaseToken))
        XCTAssertEqual(Keychain.load(.firebaseToken), "token-abc")
    }

    func test_overwrite_replacesValue() {
        _ = Keychain.save("first", for: .userId)
        _ = Keychain.save("second", for: .userId)
        XCTAssertEqual(Keychain.load(.userId), "second")
    }

    func test_delete_clearsValue() {
        _ = Keychain.save("x", for: .firebaseToken)
        XCTAssertTrue(Keychain.delete(.firebaseToken))
        XCTAssertNil(Keychain.load(.firebaseToken))
    }
}
