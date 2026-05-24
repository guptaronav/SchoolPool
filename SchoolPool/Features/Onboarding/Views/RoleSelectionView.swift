import SwiftUI

struct RoleSelectionView: View {
    @ObservedObject var vm: OnboardingViewModel

    private let roles: [(role: UserRole, icon: String, description: String)] = [
        (.student, "graduationcap.fill", "I'm a student at this school"),
        (.parent, "figure.2.and.child.holdinghands", "I'm a parent or guardian"),
        (.teacher, "book.fill", "I'm a teacher or staff member"),
        (.community, "person.3.fill", "I'm a community member")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Who are you?")
                        .font(.title.bold())
                    Text("Select your role to get started")
                        .font(.subheadline)
                        .foregroundStyle(Color.spTextSecondary)
                }
                .padding(.top, 32)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(roles, id: \.role) { item in
                        RoleCard(role: item.role, icon: item.icon, description: item.description) {
                            vm.selectRole(item.role)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color.spBackground.ignoresSafeArea())
    }
}

private struct RoleCard: View {
    let role: UserRole
    let icon: String
    let description: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundStyle(Color.spPrimary)

                Text(role.displayName)
                    .font(.headline)
                    .foregroundStyle(Color.spTextPrimary)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(Color.spTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(Color.spSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.spPrimary.opacity(0.15), lineWidth: 1)
            )
        }
    }
}
