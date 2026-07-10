import SwiftUI

struct VerificationReviewView: View {
    @StateObject private var vm: AdminViewModel
    @State private var selectedRequest: VerificationRequest?

    init(schoolId: String, verificationService: VerificationServiceProtocol) {
        _vm = StateObject(wrappedValue: AdminViewModel(schoolId: schoolId, verificationService: verificationService))
    }

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView()
                } else if vm.pendingRequests.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(Color.spAccent)
                        Text("All caught up!")
                            .font(.title2.bold())
                        Text("No pending verification requests.")
                            .foregroundStyle(Color.spTextSecondary)
                    }
                } else {
                    List(vm.pendingRequests) { request in
                        Button { selectedRequest = request } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(request.userId)
                                    .font(.headline)
                                Text(request.submittedAt.dateValue().formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(Color.spTextSecondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Verification Requests")
            .task { await vm.loadPending() }
            .sheet(item: $selectedRequest) { req in
                ReviewDetailSheet(request: req, vm: vm)
            }
        }
    }
}

private struct ReviewDetailSheet: View {
    let request: VerificationRequest
    @ObservedObject var vm: AdminViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var note = ""
    @State private var showRejectAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Applicant") {
                    LabeledContent("User ID", value: request.userId)
                    if let school = request.schoolNameFreeText {
                        LabeledContent("School", value: school)
                    }
                }
                Section("Note (optional)") {
                    TextField("Admin note", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }
                Section {
                    SPButton(title: "Approve") {
                        Task {
                            await vm.approve(request, note: note.isEmpty ? nil : note)
                            dismiss()
                        }
                    }
                    SPButton(title: "Reject", style: .danger) { showRejectAlert = true }
                }
            }
            .navigationTitle("Review Request")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
            .alert("Reject Request", isPresented: $showRejectAlert) {
                Button("Reject", role: .destructive) {
                    Task {
                        await vm.reject(request, reason: note.isEmpty ? "Rejected by admin" : note)
                        dismiss()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will notify the student their request was rejected.")
            }
        }
    }
}
