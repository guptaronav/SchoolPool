import SwiftUI

struct TripHistoryView: View {
    let user: SPUser
    let rideRepo: RideRepositoryProtocol
    let bookingService: BookingServiceProtocol
    let chatService: ChatServiceProtocol
    let ratingService: RatingServiceProtocol

    @StateObject private var vm: TripHistoryViewModel

    init(
        user: SPUser,
        rideRepo: RideRepositoryProtocol,
        bookingService: BookingServiceProtocol,
        chatService: ChatServiceProtocol,
        ratingService: RatingServiceProtocol
    ) {
        self.user = user
        self.rideRepo = rideRepo
        self.bookingService = bookingService
        self.chatService = chatService
        self.ratingService = ratingService
        _vm = StateObject(wrappedValue: TripHistoryViewModel(
            currentUserId: user.id ?? "",
            rideRepo: rideRepo
        ))
    }

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading && vm.trips.isEmpty {
                    ProgressView()
                } else if vm.trips.isEmpty {
                    ContentUnavailableView(
                        "No past trips",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("Your completed and cancelled rides will show up here.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(vm.trips) { trip in
                                NavigationLink(value: trip.id ?? "") {
                                    tripRow(trip)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(16)
                    }
                    .navigationDestination(for: String.self) { rideId in
                        RideDetailView(
                            rideId: rideId, user: user, rideRepo: rideRepo,
                            bookingService: bookingService, chatService: chatService,
                            ratingService: ratingService
                        )
                    }
                }
            }
            .background(Color.spBackground)
            .navigationTitle("Trips")
            .task { await vm.load() }
            .refreshable { await vm.load() }
        }
    }

    private func tripRow(_ trip: Ride) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                roleBadge(vm.role(for: trip))
                Spacer()
                statusChip(trip.status)
            }
            RideCard(ride: trip)
        }
    }

    private func roleBadge(_ role: TripHistoryViewModel.TripRole) -> some View {
        let isDriver = role == .driver
        return Label(isDriver ? "Drove" : "Rode",
                     systemImage: isDriver ? "steeringwheel" : "figure.seated.seatbelt")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(Color.spPrimary)
    }

    private func statusChip(_ status: RideStatus) -> some View {
        Text(status.displayName)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(status.tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(status.tint.opacity(0.12))
            .clipShape(Capsule())
    }
}
