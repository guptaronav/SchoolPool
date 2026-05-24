import Foundation

protocol VerificationServiceProtocol {
    func submit(request: VerificationRequest, documents: [Data]) async throws
    func fetchPending(forSchoolId: String) async throws -> [VerificationRequest]
    func approve(requestId: String, adminNote: String?) async throws
    func reject(requestId: String, reason: String) async throws
    func fetchLatestRequest(forUserId: String) async throws -> VerificationRequest?
}
