import SwiftUI

struct SchoolSearchView: View {
    @ObservedObject var vm: OnboardingViewModel
    let schoolRepo: SchoolRepositoryProtocol

    @State private var query = ""
    @State private var results: [School] = []
    @State private var isSearching = false
    @State private var showFreeText = false
    @State private var searchTask: Task<Void, Never>?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Find your school")
                        .font(.title.bold())
                    Text("Search for your school or district")
                        .font(.subheadline)
                        .foregroundStyle(Color.spTextSecondary)
                }
                .padding(.top, 32)

                SPTextField(title: "School name", text: $query)
                    .padding(.horizontal, 20)
                    .onChange(of: query) { _, newValue in
                        searchTask?.cancel()
                        guard newValue.count >= 2 else { results = []; return }
                        searchTask = Task {
                            try? await Task.sleep(for: .milliseconds(350))
                            guard !Task.isCancelled else { return }
                            isSearching = true
                            results = (try? await schoolRepo.search(query: newValue, limit: 20)) ?? []
                            isSearching = false
                        }
                    }

                if isSearching {
                    ProgressView()
                } else if !results.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(results) { school in
                            Button {
                                Task { await vm.selectSchool(school) }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(school.name).font(.body.weight(.medium))
                                        Text("\(school.city), \(school.state)")
                                            .font(.caption)
                                            .foregroundStyle(Color.spTextSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(Color.spTextSecondary)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 14)
                            }
                            .foregroundStyle(Color.spTextPrimary)
                            Divider().padding(.leading, 20)
                        }
                    }
                    .background(Color.spSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 20)
                }

                // Free text option
                VStack(spacing: 12) {
                    Button {
                        showFreeText.toggle()
                    } label: {
                        Text(showFreeText ? "Hide" : "My school isn't listed")
                            .font(.subheadline)
                            .foregroundStyle(Color.spPrimary)
                    }

                    if showFreeText {
                        SPTextField(title: "School name (free text)", text: $vm.freeTextSchoolName)
                            .padding(.horizontal, 20)
                        SPButton(title: "Continue with this school") {
                            // Use a placeholder school with no emailDomains -> routes to documentUpload
                            Task {
                                let placeholder = School.stub(
                                    name: vm.freeTextSchoolName,
                                    emailDomains: [],
                                    isOnboarded: false
                                )
                                await vm.selectSchool(placeholder)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
        .background(Color.spBackground.ignoresSafeArea())
    }
}
