import SwiftUI

struct MainTabView: View {
    let user: SPUser
    let userRepo: UserRepositoryProtocol
    let rideRepo: RideRepositoryProtocol
    let bookingService: BookingServiceProtocol
    let chatService: ChatServiceProtocol
    let ratingService: RatingServiceProtocol
    let verificationService: VerificationServiceProtocol
    let authService: AuthServiceProtocol
    let onSignOut: () -> Void

    private var userId: String { user.id ?? "" }

    private var isAdmin: Bool { user.role == .schoolAdmin || user.role == .superAdmin }

    var body: some View {
        TabView {
            RidesHomeView(
                user: user, rideRepo: rideRepo, bookingService: bookingService,
                chatService: chatService, ratingService: ratingService
            )
            .tabItem { Label("Rides", systemImage: "car.fill") }

            TripHistoryView(
                user: user, rideRepo: rideRepo, bookingService: bookingService,
                chatService: chatService, ratingService: ratingService
            )
            .tabItem { Label("Trips", systemImage: "clock.arrow.circlepath") }

            if isAdmin, let schoolId = user.schoolId {
                VerificationReviewView(schoolId: schoolId, verificationService: verificationService)
                    .tabItem { Label("Admin", systemImage: "checkmark.seal.fill") }
            }

            ProfileView(userId: userId, userRepo: userRepo, authService: authService, onSignOut: onSignOut)
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .tint(Color.spPrimary)
    }
}
