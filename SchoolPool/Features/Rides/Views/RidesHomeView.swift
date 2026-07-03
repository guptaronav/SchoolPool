import SwiftUI

struct RidesHomeView: View {
    let user: SPUser
    let rideRepo: RideRepositoryProtocol
    let bookingService: BookingServiceProtocol
    let chatService: ChatServiceProtocol
    let ratingService: RatingServiceProtocol

    @StateObject private var vm: RideListViewModel
    @State private var isCreating = false
    @State private var section: RideSection = .available

    private enum RideSection: String, CaseIterable {
        case available = "Available"
        case mine = "My Rides"
    }

    init(user: SPUser, rideRepo: RideRepositoryProtocol, bookingService: BookingServiceProtocol, chatService: ChatServiceProtocol, ratingService: RatingServiceProtocol) {
        self.user = user
        self.rideRepo = rideRepo
        self.bookingService = bookingService
        self.chatService = chatService
        self.ratingService = ratingService
        _vm = StateObject(wrappedValue: RideListViewModel(
            schoolId: user.schoolId ?? "",
            currentUserId: user.id ?? "",
            rideRepo: rideRepo
        ))
    }

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading && vm.rides.isEmpty && vm.myRides.isEmpty {
                    ProgressView("Finding rides...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    rideList
                }
            }
            .background(Color.spBackground)
            .navigationTitle("Rides")
            .searchable(text: $vm.searchText, prompt: "Search by place or driver")
            .safeAreaInset(edge: .bottom) {
                if user.canDrive {
                    SPButton(title: "Offer a Ride") { isCreating = true }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)
                }
            }
            .sheet(isPresented: $isCreating, onDismiss: { Task { await vm.load() } }) {
                CreateRideView(vm: makeCreateVM())
            }
            .task { await vm.load() }
            .refreshable { await vm.load() }
        }
    }

    private var rideList: some View {
        ScrollView {
            VStack(spacing: 12) {
                Picker("Section", selection: $section) {
                    ForEach(RideSection.allCases, id: \.self) { Text($0.rawValue) }
                }
                .pickerStyle(.segmented)

                let items = section == .available ? vm.filteredRides : vm.myRides
                if items.isEmpty {
                    emptyState
                        .padding(.top, 60)
                } else {
                    ForEach(items) { ride in
                        NavigationLink(value: ride.id ?? "") {
                            RideCard(ride: ride)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .navigationDestination(for: String.self) { rideId in
            RideDetailView(rideId: rideId, user: user, rideRepo: rideRepo, bookingService: bookingService, chatService: chatService, ratingService: ratingService)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: section == .available ? "car.2.fill" : "steeringwheel")
                .font(.system(size: 44))
                .foregroundStyle(Color.spPrimary.opacity(0.4))
            Text(section == .available ? "No rides available yet" : "You haven't offered any rides")
                .font(.headline)
                .foregroundStyle(Color.spTextPrimary)
            Text(section == .available
                 ? "Check back soon, or offer a ride yourself."
                 : "Tap Offer a Ride to post your first trip.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.spTextSecondary)
        }
    }

    private func makeCreateVM() -> CreateRideViewModel {
        CreateRideViewModel(
            driverId: user.id ?? "",
            driverName: user.displayName,
            schoolId: user.schoolId ?? "",
            rideRepo: rideRepo
        )
    }
}
