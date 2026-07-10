import Foundation

@MainActor
final class AdminViewModel: ObservableObject {
    @Published private(set) var pendingRequests: [VerificationRequest] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let verificationService: VerificationServiceProtocol
    private let schoolId: String

    init(schoolId: String, verificationService: VerificationServiceProtocol) {
        self.schoolId = schoolId
        self.verificationService = verificationService
    }

    func loadPending() async {
        isLoading = true
        defer { isLoading = false }
        do {
            pendingRequests = try await verificationService.fetchPending(forSchoolId: schoolId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func approve(_ request: VerificationRequest, note: String?) async {
        do {
            try await verificationService.approve(request: request, adminNote: note)
            pendingRequests.removeAll { $0.id == request.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func reject(_ request: VerificationRequest, reason: String) async {
        do {
            try await verificationService.reject(request: request, reason: reason)
            pendingRequests.removeAll { $0.id == request.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
