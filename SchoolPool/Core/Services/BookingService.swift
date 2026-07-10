import Foundation
@preconcurrency import FirebaseFirestore

enum BookingError: LocalizedError {
    case rideFull
    case alreadyRequested
    case alreadyProcessed
    case missingId

    var errorDescription: String? {
        switch self {
        case .rideFull: return "This ride is already full."
        case .alreadyRequested: return "You've already requested a seat on this ride."
        case .alreadyProcessed: return "This request was already handled."
        case .missingId: return "This request can't be processed right now."
        }
    }
}

final class BookingService: BookingServiceProtocol {
    private let db = Firestore.firestore()

    private var requests: CollectionReference { db.collection("rideRequests") }
    private var rides: CollectionReference { db.collection("rides") }

    func requestSeat(ride: Ride, riderId: String, riderName: String) async throws {
        guard let rideId = ride.id else { throw BookingError.missingId }
        guard !ride.isFull else { throw BookingError.rideFull }

        let existing = try await requests
            .whereField("rideId", isEqualTo: rideId)
            .whereField("riderId", isEqualTo: riderId)
            .whereField("status", in: [RideRequestStatus.pending.rawValue, RideRequestStatus.accepted.rawValue])
            .getDocuments()
        guard existing.documents.isEmpty else { throw BookingError.alreadyRequested }

        let request = RideRequest(
            rideId: rideId,
            riderId: riderId,
            riderName: riderName,
            driverId: ride.driverId,
            schoolId: ride.schoolId,
            status: .pending,
            createdAt: Timestamp(),
            respondedAt: nil
        )
        try requests.document().setData(from: request)
    }

    func cancelRequest(_ requestId: String) async throws {
        try await requests.document(requestId).updateData([
            "status": RideRequestStatus.cancelled.rawValue,
            "respondedAt": Timestamp()
        ])
    }

    func accept(_ request: RideRequest) async throws {
        guard let requestId = request.id else { throw BookingError.missingId }
        let rideRef = rides.document(request.rideId)
        let requestRef = requests.document(requestId)

        _ = try await db.runTransaction { transaction, errorPointer in
            do {
                // Re-read the request inside the transaction: a double-tap, a retry,
                // or a rider's concurrent cancel must not book a seat twice.
                let requestSnap = try transaction.getDocument(requestRef)
                guard let liveRequest = try? requestSnap.data(as: RideRequest.self),
                      liveRequest.status == .pending else {
                    errorPointer?.pointee = BookingError.alreadyProcessed as NSError
                    return nil
                }
                let rideSnap = try transaction.getDocument(rideRef)
                guard var ride = try? rideSnap.data(as: Ride.self), !ride.isFull else {
                    errorPointer?.pointee = BookingError.rideFull as NSError
                    return nil
                }
                guard !ride.passengerIds.contains(request.riderId) else {
                    errorPointer?.pointee = BookingError.alreadyProcessed as NSError
                    return nil
                }
                ride.seatsAvailable -= 1
                ride.passengerIds.append(request.riderId)
                if ride.isFull { ride.status = .full }

                try transaction.setData(from: ride, forDocument: rideRef, merge: true)
                transaction.updateData([
                    "status": RideRequestStatus.accepted.rawValue,
                    "respondedAt": Timestamp()
                ], forDocument: requestRef)
                return nil
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }
    }

    func decline(_ request: RideRequest) async throws {
        guard let requestId = request.id else { throw BookingError.missingId }
        try await requests.document(requestId).updateData([
            "status": RideRequestStatus.declined.rawValue,
            "respondedAt": Timestamp()
        ])
    }

    func fetchRequests(forRide rideId: String) async throws -> [RideRequest] {
        let snap = try await requests
            .whereField("rideId", isEqualTo: rideId)
            .order(by: "createdAt", descending: false)
            .getDocuments()
        return snap.documents.compactMap { try? $0.data(as: RideRequest.self) }
    }

    func fetchRequests(forRider riderId: String) async throws -> [RideRequest] {
        let snap = try await requests
            .whereField("riderId", isEqualTo: riderId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snap.documents.compactMap { try? $0.data(as: RideRequest.self) }
    }
}
