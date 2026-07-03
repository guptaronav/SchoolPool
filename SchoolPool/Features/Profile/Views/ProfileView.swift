import SwiftUI

struct ProfileView: View {
    @StateObject private var vm: ProfileViewModel
    @State private var showEdit = false
    let onSignOut: () -> Void

    private let userId: String
    private let userRepo: UserRepositoryProtocol
    private let authService: AuthServiceProtocol

    init(userId: String, userRepo: UserRepositoryProtocol, authService: AuthServiceProtocol, onSignOut: @escaping () -> Void) {
        _vm = StateObject(wrappedValue: ProfileViewModel(userId: userId, userRepo: userRepo))
        self.userId = userId
        self.userRepo = userRepo
        self.authService = authService
        self.onSignOut = onSignOut
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let user = vm.user {
                        // Avatar + name
                        VStack(spacing: 12) {
                            AvatarView(
                                urlString: user.photoURL,
                                initials: user.displayName.initials,
                                size: 80
                            )
                            Text(user.displayName)
                                .font(.title2.bold())
                            // Role badge
                            Text(user.role.displayName)
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.spPrimary.opacity(0.12))
                                .foregroundStyle(Color.spPrimary)
                                .clipShape(Capsule())
                        }
                        .padding(.top, 24)

                        // Stats row
                        HStack(spacing: 0) {
                            StatCell(label: "Droplets", value: "\(user.dropletsBalance)")
                            Divider().frame(height: 40)
                            StatCell(label: "Pool Level", value: user.poolLevel.displayName)
                            Divider().frame(height: 40)
                            StatCell(label: "Streak", value: "\(user.rideStreak)")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.spSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 24)

                        // School
                        if let schoolId = user.schoolId {
                            InfoRow(icon: "building.2", label: "School", value: schoolId)
                                .padding(.horizontal, 24)
                        }

                        Spacer(minLength: 32)

                        NavigationLink {
                            SettingsView(userId: userId, userRepo: userRepo, authService: authService, onSignOut: onSignOut)
                        } label: {
                            HStack {
                                Image(systemName: "gearshape.fill")
                                Text("Settings").fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "chevron.right").font(.caption)
                            }
                            .padding(16)
                            .background(Color.spSurface)
                            .foregroundStyle(Color.spTextPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.horizontal, 24)

                        SPButton(title: "Sign Out", style: .danger) { onSignOut() }
                            .padding(.horizontal, 24)

                    } else if vm.isLoading {
                        ProgressView()
                            .padding(.top, 80)
                    } else {
                        Text("Unable to load profile")
                            .foregroundStyle(Color.spTextSecondary)
                            .padding(.top, 80)
                    }
                }
            }
            .background(Color.spBackground.ignoresSafeArea())
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") { showEdit = true }
                        .foregroundStyle(Color.spPrimary)
                }
            }
            .sheet(isPresented: $showEdit) {
                if let user = vm.user {
                    EditProfileView(vm: vm, currentName: user.displayName)
                }
            }
            .task { await vm.load() }
        }
    }
}

private struct StatCell: View {
    let label: String
    let value: String
    var body: some View {
        VStack(spacing: 4) {
            Text(value).font(.headline.bold()).foregroundStyle(Color.spTextPrimary)
            Text(label).font(.caption).foregroundStyle(Color.spTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct InfoRow: View {
    let icon: String; let label: String; let value: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundStyle(Color.spPrimary)
            Text(label).foregroundStyle(Color.spTextSecondary)
            Spacer()
            Text(value).foregroundStyle(Color.spTextPrimary)
        }
        .padding(14)
        .background(Color.spSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
