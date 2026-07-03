import XCTest
@testable import SchoolPool

@MainActor
final class SettingsViewModelTests: XCTestCase {

    private func makeContext(
        user: SPUser = .stub()
    ) -> (vm: SettingsViewModel, repo: MockUserRepository, auth: MockAuthService) {
        let repo = MockUserRepository()
        var seeded = user
        seeded.id = seeded.id ?? "user_001"
        repo.users[seeded.id!] = seeded
        let auth = MockAuthService()
        let vm = SettingsViewModel(userId: seeded.id!, userRepo: repo, authService: auth)
        return (vm, repo, auth)
    }

    func test_load_populatesPrivacyToggles() async {
        var user = SPUser.stub()
        user.privacySettings = PrivacySettings(hidePhone: false, hideAddress: true, locationSharingConsent: true)
        let (vm, _, _) = makeContext(user: user)
        await vm.load()

        XCTAssertFalse(vm.hidePhone)
        XCTAssertTrue(vm.hideAddress)
        XCTAssertTrue(vm.locationSharingConsent)
    }

    func test_toggleHidePhone_persistsToRepository() async {
        let (vm, repo, _) = makeContext()
        await vm.load()
        vm.hidePhone = false
        await vm.savePrivacy()

        XCTAssertEqual(repo.users["user_001"]?.privacySettings.hidePhone, false)
        XCTAssertEqual(repo.updateCallCount, 1)
    }

    func test_savePrivacy_updatesAllThreeFields() async {
        let (vm, repo, _) = makeContext()
        await vm.load()
        vm.hidePhone = false
        vm.hideAddress = false
        vm.locationSharingConsent = true
        await vm.savePrivacy()

        let saved = repo.users["user_001"]?.privacySettings
        XCTAssertEqual(saved, PrivacySettings(hidePhone: false, hideAddress: false, locationSharingConsent: true))
    }

    func test_deleteAccount_callsAuthService() async {
        let (vm, _, auth) = makeContext()
        await vm.load()
        await vm.deleteAccount()

        XCTAssertEqual(auth.deleteAccountCallCount, 1)
        XCTAssertNil(vm.errorMessage)
    }

    func test_deleteAccount_setsErrorOnFailure() async {
        let (vm, _, auth) = makeContext()
        auth.shouldThrowOnDelete = true
        await vm.load()
        await vm.deleteAccount()

        XCTAssertNotNil(vm.errorMessage)
    }

    func test_savePrivacy_setsErrorOnFailure() async {
        let (vm, repo, _) = makeContext()
        await vm.load()
        repo.updateError = MockError.intentional
        vm.hidePhone = false
        await vm.savePrivacy()

        XCTAssertNotNil(vm.errorMessage)
    }
}
