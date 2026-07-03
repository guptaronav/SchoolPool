import SwiftUI

struct SettingsView: View {
    @StateObject private var vm: SettingsViewModel
    let onSignOut: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var confirmingDelete = false

    init(userId: String, userRepo: UserRepositoryProtocol, authService: AuthServiceProtocol, onSignOut: @escaping () -> Void) {
        _vm = StateObject(wrappedValue: SettingsViewModel(userId: userId, userRepo: userRepo, authService: authService))
        self.onSignOut = onSignOut
    }

    var body: some View {
        Form {
            Section("Privacy") {
                Toggle("Hide my phone number", isOn: $vm.hidePhone)
                Toggle("Hide my home address", isOn: $vm.hideAddress)
                Toggle("Share location during rides", isOn: $vm.locationSharingConsent)
            }
            .onChange(of: vm.hidePhone) { _, _ in Task { await vm.savePrivacy() } }
            .onChange(of: vm.hideAddress) { _, _ in Task { await vm.savePrivacy() } }
            .onChange(of: vm.locationSharingConsent) { _, _ in Task { await vm.savePrivacy() } }

            Section("Notifications") {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack {
                        Text("Notification Settings")
                        Spacer()
                        Image(systemName: "arrow.up.forward.app")
                            .foregroundStyle(Color.spTextSecondary)
                    }
                }
                Text("Manage push permissions in the iOS Settings app.")
                    .font(.caption)
                    .foregroundStyle(Color.spTextSecondary)
            }

            Section {
                Button("Sign Out") { onSignOut() }
                    .foregroundStyle(Color.spPrimary)
            }

            Section {
                Button("Delete Account", role: .destructive) { confirmingDelete = true }
            } footer: {
                Text("Deleting your account is permanent and removes your profile from SchoolPool.")
            }

            if let error = vm.errorMessage {
                Section {
                    Text(error).font(.footnote).foregroundStyle(Color.spDanger)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.load() }
        .alert("Delete Account?", isPresented: $confirmingDelete) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    await vm.deleteAccount()
                    if vm.errorMessage == nil { onSignOut() }
                }
            }
        } message: {
            Text("This permanently deletes your SchoolPool account. This cannot be undone.")
        }
    }
}
