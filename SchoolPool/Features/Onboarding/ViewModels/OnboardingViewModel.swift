import Foundation

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

    @Published var step: Step = .role
    @Published var selectedRole: UserRole?
    @Published var selectedSchool: School?
    @Published var freeTextSchoolName: String = ""
    @Published var studentIdNumber: String = ""
    @Published var documents: [Data] = []
    @Published var errorMessage: String?

    private let userId: String
    private let auth: AuthServiceProtocol
    private let userRepo: UserRepositoryProtocol
    private let schoolRepo: SchoolRepositoryProtocol
    private let verification: VerificationServiceProtocol

    init(userId: String,
         auth: AuthServiceProtocol,
         userRepo: UserRepositoryProtocol,
         schoolRepo: SchoolRepositoryProtocol,
         verification: VerificationServiceProtocol) {
        self.userId = userId
        self.auth = auth
        self.userRepo = userRepo
        self.schoolRepo = schoolRepo
        self.verification = verification
    }

    func selectRole(_ role: UserRole) {
        selectedRole = role
        step = .school
    }

    func selectSchool(_ school: School) async {
        selectedSchool = school
        guard var u = try? await userRepo.fetch(id: userId) else {
            errorMessage = "User not found"
            return
        }
        u.role = selectedRole ?? .student
        u.schoolId = school.id
        try? await userRepo.update(u)

        let emailParts = u.email.split(separator: "@")
        let domain = emailParts.count == 2 ? String(emailParts[1]) : ""
        if school.matches(emailDomain: domain) {
            try? await auth.sendEmailVerification()
            step = .emailWaiting
        } else {
            step = .documentUpload
        }
    }

    func submitDocuments() async {
        guard !documents.isEmpty else {
            errorMessage = "Add at least one document and your student ID"
            return
        }
        guard !studentIdNumber.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Add at least one document and your student ID"
            return
        }

        var req = VerificationRequest.stub(userId: userId, schoolId: selectedSchool?.id)
        req.studentIdNumberHash = Crypto.sha256(studentIdNumber)
        req.documentStoragePaths = []
        req.schoolNameFreeText = selectedSchool == nil ? freeTextSchoolName : nil

        do {
            try await verification.submit(request: req, documents: documents)
            step = .pendingReview
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func checkEmailVerification() async {
        try? await auth.reloadCurrentUser()
        if auth.isCurrentEmailVerified {
            step = .complete
        }
    }
}
