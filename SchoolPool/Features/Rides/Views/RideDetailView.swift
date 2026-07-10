import SwiftUI
import MapKit

struct RideDetailView: View {
    @StateObject private var vm: RideDetailViewModel
    private let user: SPUser
    private let chatService: ChatServiceProtocol
    private let ratingService: RatingServiceProtocol
    private let bookingService: BookingServiceProtocol
    @State private var isRating = false

    init(
        rideId: String,
        user: SPUser,
        rideRepo: RideRepositoryProtocol,
        bookingService: BookingServiceProtocol,
        chatService: ChatServiceProtocol,
        ratingService: RatingServiceProtocol
    ) {
        self.user = user
        self.chatService = chatService
        self.ratingService = ratingService
        self.bookingService = bookingService
        _vm = StateObject(wrappedValue: RideDetailViewModel(
            rideId: rideId,
            currentUserId: user.id ?? "",
            currentUserName: user.displayName,
            rideRepo: rideRepo,
            bookingService: bookingService
        ))
    }

    var body: some View {
        Group {
            if let ride = vm.ride {
                content(for: ride)
            } else if let error = vm.errorMessage {
                Text(error)
                    .foregroundStyle(Color.spDanger)
                    .padding()
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Ride Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if vm.canAccessChat, let rideId = vm.ride?.id {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        ChatView(rideId: rideId, user: user, chatService: chatService)
                    } label: {
                        Image(systemName: "message.fill")
                    }
                }
            }
        }
        .task { await vm.load() }
        .onAppear { vm.startObserving() }
        .onDisappear { vm.stopObserving() }
    }

    private func content(for ride: Ride) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                routeMap(for: ride)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                statusBadge(ride.status)

                RideCard(ride: ride)

                if let notes = ride.notes, !notes.isEmpty {
                    notesCard(notes)
                }

                if vm.isDriver {
                    driverLifecycleSection(for: ride)
                    if ride.status.isScheduled {
                        driverRequestsSection
                    } else {
                        passengerRoster(for: ride)
                    }
                } else {
                    riderActionSection(for: ride)
                }

                if ride.status == .completed && (vm.isDriver || vm.isPassenger) {
                    SPButton(title: "Rate Your Ride") { isRating = true }
                }

                if let error = vm.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(Color.spDanger)
                }
            }
            .padding(16)
        }
        .background(Color.spBackground)
        .sheet(isPresented: $isRating) {
            if let ride = vm.ride {
                RateRideView(ride: ride, user: user, ratingService: ratingService, bookingService: bookingService)
            }
        }
    }

    // MARK: - Rider

    @ViewBuilder
    private func riderActionSection(for ride: Ride) -> some View {
        if ride.status == .cancelled {
            statusBanner(
                icon: "xmark.circle.fill", tint: .spDanger,
                title: "Ride cancelled",
                subtitle: "\(ride.driverName) cancelled this ride."
            )
        } else {
            switch vm.myRequest?.status {
            case .pending:
                statusBanner(
                    icon: "clock.fill", tint: .spDroplet,
                    title: "Request sent",
                    subtitle: "Waiting for \(ride.driverName) to respond."
                )
                SPButton(title: "Cancel Request", style: .secondary, isLoading: vm.isWorking) {
                    Task { await vm.cancelRequest() }
                }
            case .accepted:
                statusBanner(
                    icon: "checkmark.seal.fill", tint: .spAccent,
                    title: "You're in!",
                    subtitle: "Your seat on this ride is confirmed."
                )
            default:
                if vm.canRequestSeat {
                    SPButton(title: "Request a Seat", isLoading: vm.isWorking) {
                        Task { await vm.requestSeat() }
                    }
                } else if ride.isFull {
                    statusBanner(
                        icon: "person.3.fill", tint: .spTextSecondary,
                        title: "Ride full",
                        subtitle: "All seats on this ride are taken."
                    )
                }
            }
        }
    }

    // MARK: - Driver

    private var driverRequestsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Seat Requests")
                .font(.headline)
                .foregroundStyle(Color.spTextPrimary)

            if vm.pendingRequests.isEmpty {
                Text("No pending requests yet.")
                    .font(.subheadline)
                    .foregroundStyle(Color.spTextSecondary)
            } else {
                ForEach(vm.pendingRequests) { request in
                    requestRow(request)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.spSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func requestRow(_ request: RideRequest) -> some View {
        HStack(spacing: 12) {
            AvatarView(urlString: nil, initials: request.riderName.initials, size: 40)
            Text(request.riderName)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color.spTextPrimary)
            Spacer()
            Button {
                Task { await vm.decline(request) }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color.spDanger)
            }
            Button {
                Task { await vm.accept(request) }
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color.spAccent)
            }
        }
        .disabled(vm.isWorking)
    }

    // MARK: - Lifecycle (driver)

    @ViewBuilder
    private func driverLifecycleSection(for ride: Ride) -> some View {
        VStack(spacing: 10) {
            if vm.canStartRide {
                SPButton(title: "Start Ride", isLoading: vm.isWorking) {
                    Task { await vm.startRide() }
                }
            }
            if vm.canCompleteRide {
                SPButton(title: "Complete Ride", isLoading: vm.isWorking) {
                    Task { await vm.completeRide() }
                }
            }
            if vm.canCancelRide {
                SPButton(title: "Cancel Ride", style: .danger, isLoading: vm.isWorking) {
                    Task { await vm.cancelRide() }
                }
            }
        }
    }

    private func passengerRoster(for ride: Ride) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Passengers")
                .font(.headline)
                .foregroundStyle(Color.spTextPrimary)
            if ride.passengerIds.isEmpty {
                Text("No passengers joined this ride.")
                    .font(.subheadline)
                    .foregroundStyle(Color.spTextSecondary)
            } else {
                ForEach(vm.acceptedRequests) { request in
                    HStack(spacing: 12) {
                        AvatarView(urlString: nil, initials: request.riderName.initials, size: 40)
                        Text(request.riderName)
                            .font(.subheadline)
                            .foregroundStyle(Color.spTextPrimary)
                        Spacer()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.spSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Shared

    private func statusBadge(_ status: RideStatus) -> some View {
        HStack(spacing: 6) {
            Image(systemName: status.iconName)
            Text(status.displayName)
                .fontWeight(.semibold)
        }
        .font(.caption)
        .foregroundStyle(status.tint)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(status.tint.opacity(0.12))
        .clipShape(Capsule())
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func notesCard(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Notes from driver")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(Color.spTextSecondary)
            Text(notes)
                .font(.subheadline)
                .foregroundStyle(Color.spTextPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.spSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func statusBanner(icon: String, tint: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.spTextPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.spTextSecondary)
            }
            Spacer()
        }
        .padding(16)
        .background(tint.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func routeMap(for ride: Ride) -> some View {
        let origin = CLLocationCoordinate2D(latitude: ride.origin.latitude, longitude: ride.origin.longitude)
        let destination = CLLocationCoordinate2D(latitude: ride.destination.latitude, longitude: ride.destination.longitude)
        return Map {
            Marker(ride.origin.title, systemImage: "figure.wave", coordinate: origin)
                .tint(Color.spAccent)
            Marker(ride.destination.title, coordinate: destination)
                .tint(Color.spPrimary)
        }
    }
}
