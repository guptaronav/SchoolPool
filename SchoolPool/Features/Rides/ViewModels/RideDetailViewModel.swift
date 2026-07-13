import Foundation
import Combine

@MainActor
final class RideDetailViewModel: ObservableObject {
    @Published private(set) var ride: Ride?
    @Published private(set) var myRequest: RideRequest?
    @Published private(set) var requests: [RideRequest] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isWorking = false
    @Published var errorMessage: String?

    private let rideId: String
    private let currentUserId: String
    private let currentUserName: String
    private let rideRepo: RideRepositoryProtocol
    private let bookingService: BookingServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(
        rideId: String,
        currentUserId: String,
        currentUserName: String,
        rideRepo: RideRepositoryProtocol,
        bookingService: BookingServiceProtocol
    ) {
        self.rideId = rideId
        self.currentUserId = currentUserId
        self.currentUserName = currentUserName
        self.rideRepo = rideRepo
        self.bookingService = bookingService
    }

    var isDriver: Bool { ride?.driverId == currentUserId }

    var isPassenger: Bool { ride?.hasPassenger(currentUserId) ?? false }

    /// Chat is available to the driver and confirmed passengers, and only while the ride is live or scheduled.
    var canAccessChat: Bool {
        guard let ride, !ride.status.isFinished else { return false }
        return isDriver || isPassenger
    }

    var canRequestSeat: Bool {
        guard let ride, !isDriver, !isPassenger, !ride.isFull, ride.status == .open else { return false }
        switch myRequest?.status {
        case .pending, .accepted: return false
        case .declined, .cancelled, nil: return true
        }
    }

    var pendingRequests: [RideRequest] { requests.filter(\.isPending) }

    var acceptedRequests: [RideRequest] { requests.filter { $0.status == .accepted } }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            ride = try await rideRepo.fetch(id: rideId)
            if ride == nil {
                errorMessage = "This ride is no longer available."
                return
            }
            if isDriver {
                requests = try await bookingService.fetchRequests(forRide: rideId)
            } else {
                let mine = try await bookingService.fetchRequests(forRider: currentUserId)
                myRequest = mine.first {
                    $0.rideId == rideId && ($0.status == .pending || $0.status == .accepted)
                }
            }
            startObserving()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Keeps `ride` in sync with live Firestore updates (status changes, seat counts).
    /// Idempotent; safe to call from `onAppear` when the view re-enters.
    func startObserving() {
        guard cancellables.isEmpty, ride != nil else { return }
        rideRepo.observeRide(id: rideId)
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updated in
                guard let self else { return }
                if let previousStatus = self.ride?.status, previousStatus != updated.status {
                    self.notifyStatusChange(to: updated.status)
                }
                self.ride = updated
            }
            .store(in: &cancellables)
    }

    /// Local notification for a status change — the no-Blaze substitute for a
    /// server-triggered push (Cloud Functions can't deploy without Blaze).
    private func notifyStatusChange(to status: RideStatus) {
        guard isPassenger || isDriver else { return }
        let body: String
        switch status {
        case .inProgress: body = "Your ride is starting now."
        case .completed: body = "Your ride is complete."
        case .cancelled: body = "This ride was cancelled."
        case .open, .full: return
        }
        PushNotificationManager.shared.notifyLocally(title: "SchoolPool", body: body)
    }

    /// Tears down the Firestore listener; without this it outlives the view
    /// for the whole app session.
    func stopObserving() {
        cancellables.removeAll()
        rideRepo.stopObserving(id: rideId)
    }

    func requestSeat() async {
        guard !isWorking, let ride, canRequestSeat else {
            if ride?.isFull == true { errorMessage = BookingError.rideFull.localizedDescription }
            return
        }
        isWorking = true
        defer { isWorking = false }
        do {
            try await bookingService.requestSeat(ride: ride, riderId: currentUserId, riderName: currentUserName)
            let mine = try await bookingService.fetchRequests(forRider: currentUserId)
            myRequest = mine.first { $0.rideId == rideId && $0.isPending }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func cancelRequest() async {
        guard !isWorking, let requestId = myRequest?.id else { return }
        isWorking = true
        defer { isWorking = false }
        do {
            try await bookingService.cancelRequest(requestId)
            myRequest?.status = .cancelled
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func accept(_ request: RideRequest) async {
        guard !isWorking else { return }
        isWorking = true
        defer { isWorking = false }
        do {
            try await bookingService.accept(request)
            await reloadAsDriver()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func decline(_ request: RideRequest) async {
        guard !isWorking else { return }
        isWorking = true
        defer { isWorking = false }
        do {
            try await bookingService.decline(request)
            await reloadAsDriver()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func reloadAsDriver() async {
        ride = try? await rideRepo.fetch(id: rideId)
        requests = (try? await bookingService.fetchRequests(forRide: rideId)) ?? []
    }

    // MARK: - Lifecycle (driver only)

    var canStartRide: Bool { isDriver && (ride?.status.isScheduled ?? false) }
    var canCompleteRide: Bool { isDriver && (ride?.status.isActive ?? false) }
    var canCancelRide: Bool { isDriver && (ride?.status.isScheduled ?? false) }

    func startRide() async {
        await transition(to: .inProgress, allowedFrom: { $0.isScheduled })
    }

    func completeRide() async {
        await transition(to: .completed, allowedFrom: { $0.isActive })
    }

    func cancelRide() async {
        await transition(to: .cancelled, allowedFrom: { $0.isScheduled })
    }

    private func transition(to status: RideStatus, allowedFrom: (RideStatus) -> Bool) async {
        guard !isWorking, isDriver, var current = ride, allowedFrom(current.status) else { return }
        isWorking = true
        defer { isWorking = false }
        current.status = status
        do {
            try await rideRepo.update(current)
            ride = current
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
