import XCTest
@testable import SchoolPool

final class SchoolTests: XCTestCase {
    func test_matchesEmailDomain_caseInsensitive() {
        let school = School.stub(emailDomains: ["lincoln.edu", "lhs.k12.ca.us"])
        XCTAssertTrue(school.matches(emailDomain: "Lincoln.EDU"))
        XCTAssertTrue(school.matches(emailDomain: "lhs.k12.ca.us"))
        XCTAssertFalse(school.matches(emailDomain: "other.edu"))
    }

    func test_stub_isOnboarded_byDefault() {
        let school = School.stub()
        XCTAssertTrue(school.isOnboarded)
        XCTAssertFalse(school.isPending)
    }
}
