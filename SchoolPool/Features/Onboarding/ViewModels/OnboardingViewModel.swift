import Foundation
import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {

    enum Step: Equatable {
        case role
        case school
        case emailWaiting
        case documentUpload
        case pendingReview
        case complete
    }

    @Published private(set) var step: Step = .role
    @Published private(set) var selectedRole: UserRole?
    @Published private(set) var selectedSchool: School?
    @Published private(set) var schools: [School] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    var schoolSearchText: String = "" {
        didSet {
            // Cancel the in-flight search so a slow, broader query can't
            // overwrite the results of the newer, narrower one.
            searchTask?.cancel()
            let query = schoolSearchText
            searchTask = Task { await searchSchools(query: query) }
        }
    }

    private var searchTask: Task<Void, Never>?

    private let auth: AuthServiceProtocol
    private let userRepo: UserRepositoryProtocol
    private let schoolRepo: SchoolRepositoryProtocol
    private let verificationService: VerificationServiceProtocol

    init(
        auth: AuthServiceProtocol,
        userRepo: UserRepositoryProtocol,
        schoolRepo: SchoolRepositoryProtocol,
        verificationService: VerificationServiceProtocol
    ) {
        self.auth = auth
        self.userRepo = userRepo
        self.schoolRepo = schoolRepo
        self.verificationService = verificationService
    }

    // MARK: - Step transitions

    func selectRole(_ role: UserRole) {
        selectedRole = role
        step = .school
    }

    func selectSchool(_ school: School?) {
        selectedSchool = school
        if let school, school.isOnboarded {
            step = .emailWaiting
        } else {
            step = .documentUpload
        }
    }

    func selectSchoolByEmailMatch(userEmail: String, school: School) {
        selectedSchool = school
        let domain = userEmail.components(separatedBy: "@").last ?? ""
        if school.matches(emailDomain: domain) {
            step = .emailWaiting
        } else {
            step = .documentUpload
        }
    }

    func submitDocuments(studentIdHash: String, documents: [Data]) async {
        guard !documents.isEmpty else {
            errorMessage = "Please attach at least one document."
            return
        }
        guard !studentIdHash.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter your student ID."
            return
        }
        guard let uid = auth.currentUserId else { return }

        isLoading = true
        defer { isLoading = false }

        let request = VerificationRequest(
            userId: uid,
            schoolId: selectedSchool?.id,
            schoolNameFreeText: selectedSchool?.name,
            studentIdNumberHash: Crypto.sha256(studentIdHash),
            documentStoragePaths: [],
            status: .pending,
            reviewedByAdminId: nil,
            reviewNote: nil,
            submittedAt: .init(),
            reviewedAt: nil
        )

        do {
            try await verificationService.submit(request: request, documents: documents)
            step = .pendingReview
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func checkEmailVerification() async {
        do {
            try await auth.reloadCurrentUser()
            if auth.isCurrentEmailVerified {
                step = .complete
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func sendVerificationEmail() async {
        do {
            try await auth.sendEmailVerification()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - School search

    private func searchSchools(query: String) async {
        guard query.count >= 2 else { schools = []; return }
        do {
            let results = try await schoolRepo.search(query: query, limit: 20)
            guard !Task.isCancelled else { return }
            schools = results
        } catch {
            if !Task.isCancelled { schools = [] }
        }
    }
}
