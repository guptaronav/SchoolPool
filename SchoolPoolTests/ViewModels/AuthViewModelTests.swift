import XCTest
@testable import SchoolPool

@MainActor
final class AuthViewModelTests: XCTestCase {

    func test_signInWithEmail_setsSignedInState_onSuccess() async {
        let auth = MockAuthService()
        auth.stubbedUid = "user_42"
        let vm = AuthViewModel(auth: auth, userRepo: MockUserRepository())

        await vm.signInWithEmail("a@b.c", password: "password123")

        if case .signedIn(let uid) = vm.state {
            XCTAssertEqual(uid, "user_42")
        } else {
            XCTFail("Expected .signedIn, got \(vm.state)")
        }
    }

    func test_signInAnonymously_setsSignedInState_onSuccess() async {
        let auth = MockAuthService()
        auth.stubbedUid = "guest_42"
        let vm = AuthViewModel(auth: auth, userRepo: MockUserRepository())

        await vm.signInAnonymously()

        if case .signedIn(let uid) = vm.state {
            XCTAssertEqual(uid, "guest_42")
        } else {
            XCTFail("Expected .signedIn, got \(vm.state)")
        }
        XCTAssertEqual(auth.signInAnonymouslyCallCount, 1)
    }

    func test_signInAnonymously_setsErrorState_onFailure() async {
        let auth = MockAuthService()
        auth.shouldThrowOnSignIn = true
        let vm = AuthViewModel(auth: auth, userRepo: MockUserRepository())

        await vm.signInAnonymously()

        if case .error = vm.state { } else {
            XCTFail("Expected .error, got \(vm.state)")
        }
    }

    func test_signInWithEmail_setsErrorState_onFailure() async {
        let auth = MockAuthService()
        auth.shouldThrowOnSignIn = true
        let vm = AuthViewModel(auth: auth, userRepo: MockUserRepository())

        await vm.signInWithEmail("a@b.c", password: "password123")

        if case .error = vm.state { } else {
            XCTFail("Expected .error, got \(vm.state)")
        }
    }

    func test_signOut_resetsToIdle() async {
        let auth = MockAuthService()
        let vm = AuthViewModel(auth: auth, userRepo: MockUserRepository())
        await vm.signInWithEmail("a@b.c", password: "x")

        vm.signOut()

        if case .idle = vm.state { } else {
            XCTFail("Expected .idle after sign out, got \(vm.state)")
        }
    }
}
