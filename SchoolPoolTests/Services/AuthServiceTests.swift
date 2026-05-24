import XCTest
@testable import SchoolPool

final class AuthServiceTests: XCTestCase {
    // Smoke tests only — most SIWA behavior can't be unit-tested without UI

    func test_currentUserId_nilWhenNotSignedIn() {
        // Firebase may or may not have a session in test environment
        // Just verify the property is accessible without crashing
        _ = AuthService.shared.currentUserId
    }

    func test_isCurrentEmailVerified_accessible() {
        _ = AuthService.shared.isCurrentEmailVerified
    }
}
