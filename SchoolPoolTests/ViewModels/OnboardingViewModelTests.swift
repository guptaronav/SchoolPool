import XCTest
@testable import SchoolPool

@MainActor
final class OnboardingViewModelTests: XCTestCase {

    private func makeVM(
        auth: MockAuthService = MockAuthService(),
        schoolRepo: MockSchoolRepository = MockSchoolRepository(),
        verificationService: MockVerificationService = MockVerificationService()
    ) -> OnboardingViewModel {
        OnboardingViewModel(
            auth: auth,
            userRepo: MockUserRepository(),
            schoolRepo: schoolRepo,
            verificationService: verificationService
        )
    }

    func test_selectRole_advancesToSchoolStep() {
        let vm = makeVM()
        vm.selectRole(.student)
        XCTAssertEqual(vm.step, .school)
        XCTAssertEqual(vm.selectedRole, .student)
    }

    func test_selectSchoolByEmailMatch_withMatchingDomain_routesToEmailWaiting() {
        let vm = makeVM()
        let school = School.stub(emailDomains: ["lincoln.edu"])
        vm.selectSchoolByEmailMatch(userEmail: "student@lincoln.edu", school: school)
        XCTAssertEqual(vm.step, .emailWaiting)
    }

    func test_selectSchoolByEmailMatch_withNonMatchingDomain_routesToDocumentUpload() {
        let vm = makeVM()
        let school = School.stub(emailDomains: ["lincoln.edu"])
        vm.selectSchoolByEmailMatch(userEmail: "student@other.edu", school: school)
        XCTAssertEqual(vm.step, .documentUpload)
    }

    func test_submitDocuments_withEmptyDocuments_setsErrorMessage() async {
        let vm = makeVM()
        await vm.submitDocuments(studentIdHash: "12345", documents: [])
        XCTAssertNotNil(vm.errorMessage)
    }

    func test_submitDocuments_withEmptyStudentId_setsErrorMessage() async {
        let vm = makeVM()
        await vm.submitDocuments(studentIdHash: "  ", documents: [Data([1, 2, 3])])
        XCTAssertNotNil(vm.errorMessage)
    }
}
