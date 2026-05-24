import XCTest
@testable import SchoolPool

@MainActor
final class OnboardingViewModelTests: XCTestCase {

    private func makeVM(userId: String = "user_001") -> (OnboardingViewModel, MockAuthService, MockUserRepository, MockSchoolRepository, MockVerificationService) {
        let auth = MockAuthService()
        let userRepo = MockUserRepository()
        let schoolRepo = MockSchoolRepository()
        let verification = MockVerificationService()
        let vm = OnboardingViewModel(
            userId: userId,
            auth: auth,
            userRepo: userRepo,
            schoolRepo: schoolRepo,
            verification: verification
        )
        return (vm, auth, userRepo, schoolRepo, verification)
    }

    func test_selectRole_advancesToSchoolStep() {
        let (vm, _, _, _, _) = makeVM()
        vm.selectRole(.student)
        XCTAssertEqual(vm.step, .school)
        XCTAssertEqual(vm.selectedRole, .student)
    }

    func test_selectSchool_matchingDomain_routesToEmailWaiting() async {
        let (vm, _, userRepo, _, _) = makeVM()
        var user = SPUser.stub(email: "alex@lincoln.edu")
        user.id = "user_001"
        userRepo.users["user_001"] = user

        let school = School.stub(emailDomains: ["lincoln.edu"])
        vm.selectRole(.student)
        await vm.selectSchool(school)

        XCTAssertEqual(vm.step, .emailWaiting)
    }

    func test_selectSchool_nonMatchingDomain_routesToDocumentUpload() async {
        let (vm, _, userRepo, _, _) = makeVM()
        var user = SPUser.stub(email: "alex@gmail.com")
        user.id = "user_001"
        userRepo.users["user_001"] = user

        let school = School.stub(emailDomains: ["lincoln.edu"])
        vm.selectRole(.student)
        await vm.selectSchool(school)

        XCTAssertEqual(vm.step, .documentUpload)
    }

    func test_submitDocuments_emptyDocuments_setsErrorMessage() async {
        let (vm, _, _, _, _) = makeVM()
        vm.documents = []
        vm.studentIdNumber = "12345"

        await vm.submitDocuments()

        XCTAssertNotNil(vm.errorMessage)
    }
}
