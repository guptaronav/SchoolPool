import Foundation
@testable import SchoolPool

final class MockVerificationService: VerificationServiceProtocol {
    var pendingRequests: [VerificationRequest] = []
    var submitError: Error?
    var approveError: Error?
    var rejectError: Error?

    private(set) var submitCallCount = 0
    private(set) var approveCallCount = 0
    private(set) var rejectCallCount = 0

    func submit(request: VerificationRequest, documents: [Data]) async throws {
        submitCallCount += 1
        if let submitError { throw submitError }
        pendingRequests.append(request)
    }

    func fetchPending(forSchoolId: String) async throws -> [VerificationRequest] {
        pendingRequests.filter { $0.schoolId == forSchoolId && $0.status == .pending }
    }

    func approve(requestId: String, adminNote: String?) async throws {
        approveCallCount += 1
        if let approveError { throw approveError }
        if let idx = pendingRequests.firstIndex(where: { $0.id == requestId }) {
            pendingRequests[idx].status = .approved
        }
    }

    func reject(requestId: String, reason: String) async throws {
        rejectCallCount += 1
        if let rejectError { throw rejectError }
        if let idx = pendingRequests.firstIndex(where: { $0.id == requestId }) {
            pendingRequests[idx].status = .rejected
        }
    }

    func fetchLatestRequest(forUserId: String) async throws -> VerificationRequest? {
        pendingRequests.filter { $0.userId == forUserId }.last
    }
}
