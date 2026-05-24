import SwiftUI

struct EditProfileView: View {
    @ObservedObject var vm: ProfileViewModel
    @State private var name: String
    @Environment(\.dismiss) private var dismiss

    init(vm: ProfileViewModel, currentName: String) {
        self.vm = vm
        _name = State(initialValue: currentName)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Display Name") {
                    TextField("Name", text: $name)
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await vm.update(displayName: name)
                            dismiss()
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
