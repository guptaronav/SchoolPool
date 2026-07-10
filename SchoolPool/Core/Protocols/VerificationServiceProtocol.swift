import Foundation

protocol VerificationServiceProtocol {
    func submit(request: VerificationRequest, documents: [Data]) async throws
    func fetchPending(forSchoolId: String) async throws -> [VerificationRequest]
    func approve(request: VerificationRequest, adminNote: String?) async throws
    func reject(request: VerificationRequest, reason: String) async throws
}
