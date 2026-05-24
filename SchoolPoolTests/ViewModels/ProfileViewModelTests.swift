import XCTest
@testable import SchoolPool

@MainActor
final class ProfileViewModelTests: XCTestCase {

    func test_load_populatesUser() async {
        let repo = MockUserRepository()
        var u = SPUser.stub()
        u.id = "user_001"
        repo.users["user_001"] = u

        let vm = ProfileViewModel(userId: "user_001", userRepo: repo)
        await vm.load()

        XCTAssertNotNil(vm.user)
        XCTAssertEqual(vm.user?.displayName, "Alex Johnson")
    }

    func test_load_setsErrorOnFailure() async {
        let repo = MockUserRepository()
        repo.fetchError = MockError.intentional

        let vm = ProfileViewModel(userId: "user_001", userRepo: repo)
        await vm.load()

        XCTAssertNil(vm.user)
        XCTAssertNotNil(vm.errorMessage)
    }

    func test_update_changesDisplayName() async {
        let repo = MockUserRepository()
        var u = SPUser.stub()
        u.id = "user_001"
        repo.users["user_001"] = u

        let vm = ProfileViewModel(userId: "user_001", userRepo: repo)
        await vm.load()
        await vm.update(displayName: "Jordan Smith")

        XCTAssertEqual(vm.user?.displayName, "Jordan Smith")
        XCTAssertEqual(repo.users["user_001"]?.displayName, "Jordan Smith")
    }
}
