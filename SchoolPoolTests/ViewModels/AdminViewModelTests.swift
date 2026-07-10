import XCTest
@testable import SchoolPool

@MainActor
final class AdminViewModelTests: XCTestCase {

    private func makeVM(service: MockVerificationService = MockVerificationService()) -> AdminViewModel {
        AdminViewModel(schoolId: "school_001", verificationService: service)
    }

    func test_loadPending_populatesRequests() async {
        let service = MockVerificationService()
        service.pendingRequests = [
            VerificationRequest.stub(userId: "u1", schoolId: "school_001", status: .pending),
            VerificationRequest.stub(userId: "u2", schoolId: "school_001", status: .pending)
        ]
        let vm = makeVM(service: service)
        await vm.loadPending()
        XCTAssertEqual(vm.pendingRequests.count, 2)
    }

    func test_approve_removesFromLocalList() async {
        let service = MockVerificationService()
        var req = VerificationRequest.stub(userId: "u1", schoolId: "school_001", status: .pending)
        req.id = "req_001"
        service.pendingRequests = [req]

        let vm = makeVM(service: service)
        await vm.loadPending()
        await vm.approve(req, note: "Looks good")

        XCTAssertTrue(vm.pendingRequests.isEmpty)
    }

    func test_reject_removesFromLocalList() async {
        let service = MockVerificationService()
        var req = VerificationRequest.stub(userId: "u1", schoolId: "school_001", status: .pending)
        req.id = "req_002"
        service.pendingRequests = [req]

        let vm = makeVM(service: service)
        await vm.loadPending()
        await vm.reject(req, reason: "Invalid document")

        XCTAssertTrue(vm.pendingRequests.isEmpty)
    }
}
