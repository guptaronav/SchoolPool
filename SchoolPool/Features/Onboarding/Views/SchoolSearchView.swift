import SwiftUI

struct SchoolSearchView: View {
    @ObservedObject var vm: OnboardingViewModel
    let userEmail: String

    @State private var showFreeText = false
    @State private var freeTextSchoolName = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Find your school")
                        .font(.largeTitle.bold())
                    Text("Search for your school to connect with your community")
                        .font(.subheadline)
                        .foregroundStyle(Color.spTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)

                // Search field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.spTextSecondary)
                    TextField("Type school name…", text: Binding(
                        get: { vm.schoolSearchText },
                        set: { vm.schoolSearchText = $0 }
                    ))
                }
                .padding(12)
                .background(Color.spSurface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.spTextSecondary.opacity(0.2)))
                .padding(.horizontal, 24)

                // Results
                if !vm.schools.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(vm.schools) { school in
                            Button {
                                vm.selectSchoolByEmailMatch(userEmail: userEmail, school: school)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(school.name).font(.headline).foregroundStyle(Color.spTextPrimary)
                                        Text("\(school.city), \(school.state)").font(.caption).foregroundStyle(Color.spTextSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundStyle(Color.spTextSecondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                            }
                            Divider().padding(.leading, 16)
                        }
                    }
                    .background(Color.spSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 24)
                }

                // Free-text fallback
                VStack(spacing: 12) {
                    Button {
                        withAnimation { showFreeText.toggle() }
                    } label: {
                        Label("My school isn't listed", systemImage: "plus.circle")
                            .font(.subheadline)
                            .foregroundStyle(Color.spPrimary)
                    }

                    if showFreeText {
                        SPTextField(title: "School name", text: $freeTextSchoolName)
                            .padding(.horizontal, 24)

                        SPButton(title: "Continue with this school") {
                            let stubSchool = School(
                                name: freeTextSchoolName,
                                district: nil,
                                city: "",
                                state: "",
                                country: "US",
                                emailDomains: [],
                                adminUserIds: [],
                                isOnboarded: false,
                                isPending: true,
                                createdAt: .init(),
                                studentCount: 0
                            )
                            vm.selectSchool(stubSchool)
                        }
                        .padding(.horizontal, 24)
                    }
                }
            }
            .padding(.bottom, 32)
        }
        .background(Color.spBackground.ignoresSafeArea())
    }
}
