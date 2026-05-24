import XCTest
@testable import SchoolPool

final class CryptoTests: XCTestCase {
    func test_sha256_knownVector() {
        // "abc" -> ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
        XCTAssertEqual(
            Crypto.sha256("abc"),
            "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
        )
    }

    func test_sha256_emptyString() {
        XCTAssertEqual(
            Crypto.sha256(""),
            "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        )
    }

    func test_sha256_isDeterministic() {
        XCTAssertEqual(Crypto.sha256("student-id-12345"), Crypto.sha256("student-id-12345"))
    }
}
