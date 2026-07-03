import SwiftUI

struct CreateRideView: View {
    @ObservedObject var vm: CreateRideViewModel
    @Environment(\.dismiss) private var dismiss

    private enum PickerTarget: Identifiable {
        case origin, destination
        var id: Self { self }
    }
    @State private var pickerTarget: PickerTarget?

    var body: some View {
        NavigationStack {
            Form {
                Section("Route") {
                    locationRow(label: "From", location: vm.origin) { pickerTarget = .origin }
                    locationRow(label: "To", location: vm.destination) { pickerTarget = .destination }
                }

                Section("Departure") {
                    DatePicker("Leaving at", selection: $vm.departureDate, in: Date()...)
                }

                Section("Seats & Price") {
                    Stepper("Seats: \(vm.seats)", value: $vm.seats, in: CreateRideViewModel.seatRange)
                    HStack {
                        Text("Price per seat")
                        Spacer()
                        TextField("Free", value: $vm.pricePerSeat, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                }

                Section("Notes") {
                    TextField("Anything riders should know?", text: $vm.notes, axis: .vertical)
                        .lineLimit(2...4)
                }

                if let error = vm.errorMessage {
                    Section {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(Color.spDanger)
                    }
                }
            }
            .navigationTitle("Offer a Ride")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    if vm.isSubmitting {
                        ProgressView()
                    } else {
                        Button("Post") {
                            Task { await vm.submit() }
                        }
                        .disabled(!vm.canSubmit)
                    }
                }
            }
            .sheet(item: $pickerTarget) { target in
                LocationSearchView(title: target == .origin ? "Pickup Location" : "Drop-off Location") { location in
                    switch target {
                    case .origin: vm.origin = location
                    case .destination: vm.destination = location
                    }
                }
            }
            .onChange(of: vm.didSubmit) { _, submitted in
                if submitted { dismiss() }
            }
        }
    }

    private func locationRow(label: String, location: RideLocation?, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .foregroundStyle(Color.spTextPrimary)
                Spacer()
                Text(location?.title ?? "Choose...")
                    .foregroundStyle(location == nil ? Color.spTextSecondary : Color.spPrimary)
                    .lineLimit(1)
            }
        }
    }
}
