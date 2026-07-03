import SwiftUI

struct RateRideView: View {
    @StateObject private var vm: RateRideViewModel
    @Environment(\.dismiss) private var dismiss

    init(
        ride: Ride,
        user: SPUser,
        ratingService: RatingServiceProtocol,
        bookingService: BookingServiceProtocol
    ) {
        _vm = StateObject(wrappedValue: RateRideViewModel(
            ride: ride,
            currentUserId: user.id ?? "",
            ratingService: ratingService,
            bookingService: bookingService
        ))
    }

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView()
                } else if vm.participants.isEmpty {
                    ContentUnavailableView("Nothing to rate", systemImage: "star.slash",
                                           description: Text("There's no one to rate for this ride."))
                } else {
                    List {
                        ForEach(vm.participants) { participant in
                            RatePersonRow(participant: participant, vm: vm)
                        }
                    }
                }
            }
            .navigationTitle("Rate Your Ride")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
            .task { await vm.load() }
        }
    }
}

private struct RatePersonRow: View {
    let participant: RateableParticipant
    @ObservedObject var vm: RateRideViewModel

    @State private var stars = 5
    @State private var comment = ""

    var body: some View {
        Section {
            HStack {
                AvatarView(urlString: nil, initials: participant.name.initials, size: 40)
                VStack(alignment: .leading) {
                    Text(participant.name)
                        .font(.subheadline).fontWeight(.medium)
                    Text(participant.roleLabel)
                        .font(.caption).foregroundStyle(Color.spTextSecondary)
                }
                Spacer()
            }

            if vm.hasRated(participant.id) {
                Label("Rated — thank you!", systemImage: "checkmark.seal.fill")
                    .font(.subheadline)
                    .foregroundStyle(Color.spAccent)
            } else {
                StarRatingPicker(rating: $stars)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 4)
                TextField("Add a comment (optional)", text: $comment, axis: .vertical)
                    .lineLimit(1...3)
                Button {
                    Task { await vm.submit(rateeId: participant.id, stars: stars, comment: comment) }
                } label: {
                    if vm.isSubmitting {
                        ProgressView()
                    } else {
                        Text("Submit Rating").fontWeight(.semibold)
                    }
                }
                .disabled(vm.isSubmitting)
            }
        }
    }
}
